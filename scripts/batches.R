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

save_all_warnings <- function(expr, logfile, header) {
  if(file.exists(logfile)) logfile <- paste0(logfile,".1")
  cat(header, "\n\n",  file=logfile, append=FALSE)
  withCallingHandlers(expr, 
                      warning=function(w) {
                        cat(conditionMessage(w), "\n\n",  file=logfile, append=TRUE)
                        invokeRestart("muffleWarning")
                      } )
}

mdfile = "../check.md"
print_to_md <- function(msg, append=TRUE) {
  cat(msg,"\n\n",  file=mdfile, append=append)
}


plot_batch <- function(racine, alias, suffix, 
                       ggs.path,
                       relations, depth,
                       node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                       node_label = "alias", node_type = "text",
                       edge_label = FALSE,
                       ggs.width = 10.66, ggs.heigth = 6, ggs.dpi = 200,
                       double_thres = 50
                       ) {

  print(paste("Racine :",racine,alias,"(",suffix,")"))
  print_to_md(paste0("### ", stringr::str_to_title(suffix)," ",alias," https://www.wikidata.org/wiki/",racine))
  alias <- stringr::str_replace_all(alias," ","_")
  basefile = paste0(ggs.path,"/",alias,'-',racine,"-",suffix)
  
  try( {
    save_all_warnings(
      df <- wdesr_get_graph(racine, relations, depth=depth), 
      paste0("../plots/",basefile,".log"),
      paste0("Warnings pour : ",alias,"\nEdition wikidata : https://www.wikidata.org/wiki/",racine ))
    
    mult <- ifelse(nrow(df$vertices)<double_thres, 1, 2)
    
    wdesr_ggplot_graph(df,
                       node_size = node_size/mult, label_sizes = label_sizes/mult, arrow_gap = arrow_gap/mult,
                       node_label = node_label, node_type = node_type,
                       edge_label = edge_label)
    
    ggsave(paste0("../plots/",basefile,".png"), 
           width = ggs.width, height = ggs.heigth, dpi = ggs.dpi)  
    
    print_to_md(paste0("![](plots/",basefile,".png)"))
  } )
  
  print_to_md(paste0("[Avertissements et édition](plots/",basefile,".log)"))
  
}


# Chargement du cache s'il existe. 
# Sinon, les données seront téléchargées sur wikidate.
wdesr_load_cache()

print_to_md("# Batches de représentation wikidataESR", append=FALSE)
print_to_md("https://github.com/cpesr/WikidataESR")

print_to_md(paste(sep='\n',"```",
"  - twtexte:[#DataESR #HelpESR] Visualisation des organisations de l'#ESR.",
"  - twalt:@juliengossa LO 2.0 www.cpesr.fr",
"  - twurl:https://twitter.com/CPESR_/status/1457453241378148361",
"```"))

## Charge les établissements, puis plote par type
etab <- read.csv2("fr-esr-principaux-etablissements-enseignement-superieur.csv") %>%
  transmute(
    wdid = Identifiant.wikidata,
    alias = ifelse(nom_court=="",Libellé,nom_court),
    type = type.d.établissement,
    twitter = compte_twitter 
  ) %>%
  filter(wdid != "") %>%
  filter(type %in% c("Université", "Grand établissement")) %>%
  nest_by(type) %>% 
  arrange(desc(type))

for(i in 1:nrow(etab)) {
  t <- etab[i,1]$type
  print_to_md(paste0("## Histoire, composition et association des ",t," actuels"))
  
  subetab <- etab[i,2]$data[[1]]
  for (i in 1:nrow(subetab)) {
    wdid <- subetab[i,1]$wdid
    alias <- paste(subetab[i,2]$alias,
                   stringr::str_replace(subetab[i,3]$twitter, "https://twitter.com/", "@"))
    
    plot_batch(wdid,alias, "histoire",
               "etablissements",
               c('séparé_de', 'prédécesseur'), depth=10)
    
    plot_batch(wdid,alias, "composition",
               "etablissements",
               c('composante'), depth=10)
  
    plot_batch(wdid,alias, "associations",
               "etablissements",
               c('composante_de','associé','associé_de'), depth=5)
    
  }
}



print_to_md("## Regroupements")

# Lecture des id wikidata des racines pour les regroupements, puis plot.
regroupements <- read.csv2("regroupements.csv")
for(i in 1:nrow(regroupements)) {
  plot_batch(regroupements[i,1],regroupements[i,2], "regroupement-court",
             "regroupements",
             relations = c('composante','associé'), depth = 1)
  plot_batch(regroupements[i,1],regroupements[i,2], "regroupement-etendu",
             "regroupements",
             relations = c('composante','associé'), depth = 2)
  plot_batch(regroupements[i,1],regroupements[i,2], "regroupement-superetendu",
             "regroupements",
             relations = c('composante','associé','prédécesseur'), depth = 3,
             ggs.width = 16, ggs.heigth = 9)
}


print_to_md("## Histoire des universités historiques")

## Charge les racines et puis plote les graphiques.
anciennes_univ <- read.table("anciennes_univ.csv", sep = ";", header = TRUE, quote="")
for(i in 1:nrow(anciennes_univ))
  plot_batch(anciennes_univ[i,1],anciennes_univ[i,2], "histoire",
             "histoire",
             c('successeur', 'séparé_de', 'composante_de', 'associé_de'), depth=10,
             double_thres = 20)



# Enregistre le cache pour éviter d'avoir à retélécharger les données la prochaine fois.
wdesr_save_cache()

