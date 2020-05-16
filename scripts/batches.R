# This file is part of wikidataESR.
#
# wikidataESR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# wikidataESR is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Author: Julien Gossa <gossa@unistra.fr>
#
# Ce script permet de créer un large nombre de graphes.
# Le résultat peut être trouvé là : https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/plots
# Deux dossiers doivent être créés pour qu'il fonctionne (../plots/histoire and ../plots/regroupements)
# 
# Ce code peut servir d'exemple pour construire d'autres applications.

library(wikidataESR)

library(ggplot2)
library(network)
library(ggnetwork)
library(scales)
library(dplyr)


# Chargement du cache s'il existe. 
# Sinon, les données seront téléchargées sur wikidate.
wdesr_load_cache()

## Regroupements
# Ces graphiques partent d'un regroupement (COMUE, association, site) 
# et suivent les propriétés 'composante' et 'associé' pour retrouver
# tous les établissements qui y sont rattachés.

# Cette fonction produit les graphes de regroupement
plot_regroupements <- function(racines) {
  wdesr.env <- wdesr_get_cache()
  ggs.width <- 13
  ggs.heigth <- 8
  ggs.dpi <- 150
  ggs.path <- "../plots/regroupements/"
  
  for(racine in racines) {
    print(paste("Racine :",racine))

    ## court
    try( {
      wdesr_load_and_plot(racine,c('composante','associé'),depth=1, 
                          node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                          node_label = "alias", node_type = "text",
                          edge_label = FALSE)
      alias <- subset(wdesr.env$items, id == racine)$alias
      ggsave(paste(ggs.path,alias,'-',racine,"-court.png",sep=''), width = ggs.width, height = ggs.heigth, dpi = ggs.dpi) 
    } )
        
    ## étendu
    try( {
      wdesr_load_and_plot(racine,c('composante','associé'),depth=2, active_only = TRUE,
                          node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                          node_label = "alias", node_type = "text",
                          edge_label = FALSE)
      ggsave(paste(ggs.path,alias,'-',racine,"-etendu.png",sep=''), width = ggs.width, height = ggs.heigth, dpi = ggs.dpi) 
      } )

    ## superétendu
    try( {
      wdesr_load_and_plot(racine,c('composante','associé','prédécesseur'),depth=3,
                          node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                          node_label = "alias", node_type = "text",
                          edge_label = FALSE)
      ggsave(paste(ggs.path,alias,'-',racine,"-superetendu.png",sep=''), width = ggs.width, height = ggs.heigth, dpi = ggs.dpi)  
    } )
    
  }
}

# Lecture des id wikidata des racines pour les regroupements, puis plot.
regroupements <- read.table("regroupements.csv", sep = ";", header = TRUE, quote="")
plot_regroupements(regroupements$id)


## Histoire
# Ces graphiques partent d'une université disparue dans les années '70
# et suivent les propriétés 'successeur', 'séparé_de', 'composante_de' et 'associé_de' pour retrouver
# tous les établissements qui y sont rattachés.

plot_histoire <- function(racines) {
  wdesr.env <- wdesr_get_cache()
  ggs.width <- 8
  ggs.heigth <- 6
  ggs.dpi <- 200
  ggs.path <- "../plots/histoire/"
  
  for(racine in racines) {
    alias <- subset(wdesr.env$items, id == racine)$alias
    print(paste("Racine :",racine,alias))
    
    ## histoire
    try( {
      wdesr_load_and_plot(racine,c('successeur', 'séparé_de', 'composante_de', 'associé_de'), depth=10,
                          node_size = 25, label_sizes = 3, arrow_gap = 0.09,
                          node_label = "alias_date", node_type = "text",
                          edge_label = TRUE)
      alias <- subset(wdesr.env$items, id == racine)$alias
      ggsave(paste(ggs.path,alias,'-',racine,"-histoire.png",sep=''), width = ggs.width, height = ggs.heigth, dpi = ggs.dpi)  
    } )
  }
  
  # Paris sera toujours une exception
  racine <- "Q209842"
  wdesr_load_and_plot(racine,c('successeur', 'séparé_de', 'composante_de', 'associé_de'), depth=10,
                      node_size = 10, label_sizes = 2.5, arrow_gap = 0.03,
                      node_label = "alias", node_type = "text",
                      edge_label = TRUE)
  alias <- subset(wdesr.env$items, id == racine)$alias
  ggsave(paste(ggs.path,alias,'-',racine,"-histoire-etendu.png",sep=''), width = ggs.width, height = ggs.heigth, dpi = ggs.dpi)  

  wdesr_load_and_plot(racine,c('successeur', 'séparé_de', 'composante_de', 'associé_de'), depth=10, active_only = TRUE,
                      node_size = 10, label_sizes = 2.5, arrow_gap = 0.03,
                      node_label = "alias", node_type = "text",
                      edge_label = TRUE)
  alias <- subset(wdesr.env$items, id == racine)$alias
  ggsave(paste(ggs.path,alias,'-',racine,"-histoire.png",sep=''), width = ggs.width, height = ggs.heigth, dpi = ggs.dpi)  
  
}

## Charge les racines et puis plote les graphiques.
anciennes_univ <- read.table("anciennes_univ.csv", sep = ";", header = TRUE, quote="")
plot_histoire(anciennes_univ$id)

# Enregistre le cache pour éviter d'avoir à retélécharger les données la prochaine fois.
wdesr_save_cache()
