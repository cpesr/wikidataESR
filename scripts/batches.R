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
library(stringr)

library(ggcpesrthemes)
theme_cpesr_setup(authors = "Julien Gossa", url = "www.cpesr.fr WikidataESR")

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
print_to_md <- function(msg, file=mdfile, append=TRUE) {
  cat(msg,"\n\n", file=file, append=append)
}

start_logfile <- function(racine, alias, logfile) {
  cat("Warnings wikidataESR pour : ",alias,"(",format(Sys.time(), '%d/%m/%Y'),"\n================\n\n", 
      file=logfile, sep='' )
  cat("- Edition wikidata : [",racine,"](https://www.wikidata.org/wiki/",racine,")\n", 
      file = logfile, append = TRUE, sep='')
  cat("- Guide d'édition : [wikidataESR](https://github.com/cpesr/wikidataESR/)\n\n", 
      file = logfile, append = TRUE, sep='')
  cat("- Discussion sur le guide d'édition : [github](https://github.com/cpesr/wikidataESR/issues)\n\n", 
      file = logfile, append = TRUE, sep='')
}

plot_batch <- function(racine, alias, suffix, 
                       ggs.path,
                       relations, depth,
                       node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                       node_label = "alias", node_type = "text",
                       edge_label = FALSE,
                       active_only = FALSE,
                       ggs.width = 10.66, ggs.heigth = 6, ggs.dpi = 200,
                       append_logfile = FALSE
                       ) {

  print(paste("Racine :",racine,alias,"(",suffix,")"))

  githuburl = "https://github.com/cpesr/wikidataESR/blob/master/"
  logfile = paste0("../plots/",ggs.path,"/",racine,".md")
  logurl = paste0("plots/",ggs.path,"/",racine,".md")
  plotfilename = paste0(racine,"-",suffix,".png")
  plotfile = paste0("../plots/",ggs.path,"/",plotfilename)
  ploturl = paste0("plots/",ggs.path,"/",plotfilename)
  
  if(!append_logfile) start_logfile(racine,alias,logfile)
  print_to_md(paste0("### ",alias," : ",str_to_title(str_replace(suffix,'-',' ')),
                     ".     Edition des données : ", githuburl,logurl))
  print_to_md(paste0("\n\n## ",suffix), file=logfile)
  print_to_md(paste0("![Graphique non généré](",plotfilename,")"), file=logfile)
  
  tryCatch( {
    df <- wdesr_get_graph(racine, relations, depth=depth, active_only = active_only)
    
    print_to_md(wdesr_log_warnings(df),logfile)
    
    mult.ggs <- 1 ; mult.margin <- 1
    
    
    if(nrow(df$vertices)<16)    { mult.ggs <- 0.9 ; mult.margin <- 1.6 }
    if(nrow(df$vertices)<6)     { mult.ggs <- 0.7 ; mult.margin <- 2.0 }
    if(nrow(df$vertices)>=50)   { mult.ggs <- 1.3 ; mult.margin <- 0.5 }
    if(nrow(df$vertices)>=100)  { mult.ggs <- 2.0 ; mult.margin <- 0.1 }
    if(nrow(df$vertices)>=150)  { mult.ggs <- 2.5 ; mult.margin <- 0.1 }
    if (racine == "Q209842")    { mult.ggs <- 1.5 ; mult.margin <- 0.5 }
    
    wdesr_ggplot_graph(df,
                       node_size = node_size, label_sizes = label_sizes, arrow_gap = arrow_gap,
                       node_label = node_label, node_type = node_type,
                       edge_label = edge_label,
                       margin_x = 0.2*mult.margin, margin_y = 0.03*mult.margin) +
      ggtitle(paste(stringr::str_to_sentence(suffix),"de",alias)) +
      cpesr_cap()

    ggsave(plotfile, width = ggs.width*mult.ggs, height = ggs.heigth*mult.ggs, dpi = ggs.dpi)  
    
    print_to_md(paste0("![](",ploturl,")"))
  },
    error = function(c) {
      print_to_md(paste0("\nErreur : les données sont probablement trop partielles.\n```\n", c,"\n```"))
      print_to_md(paste0("\nErreur : les données sont probablement trop partielles.\n```\n", c,"\n```"), file=logfile)
    }
  )
  print_to_md(paste0("Avertissements et édition : [logs](",logurl,")"))
  
}


# Chargement du cache s'il existe. 
# Sinon, les données seront téléchargées sur wikidate.
wdesr_load_cache()

setwd("scripts")



print_to_md("Batches de représentation wikidataESR\n================\n\n", append=FALSE)
print_to_md(format(Sys.time(), '%d/%m/%Y'))
print_to_md("https://github.com/cpesr/WikidataESR")

print_to_md(paste(sep='\n',"```",
"  - twtexte:[#DataESR #HelpESR] Visualisation des @wikidata de l'#ESR.",
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
  mutate(wdid = case_when(
    wdid == "Q13531686" ~ "Q109409389", # Paris-Saclay,
    TRUE ~ wdid
  )) %>%
  filter(type %in% c("Université", "Grand établissement")) %>%
  nest_by(type) %>% 
  arrange(desc(type))



for(i in 1:nrow(etab)) {
  t <- etab[i,1]$type
  print_to_md(paste0("## Histoire, composition et association actuelles des ",t))

  subetab <- etab[i,2]$data[[1]]
  
  print_to_md(paste0("Twitters manquants :\n```\n",
                     paste0(" - ", subetab %>% filter(twitter=="") %>% pull(alias), collapse = "\n"),
                     "\n```"))
  
  for (i in 1:nrow(subetab)) {
    wdid <- subetab[i,1]$wdid
    alias <- paste(subetab[i,2]$alias,
                   stringr::str_replace(subetab[i,3]$twitter, "https://twitter.com/", "@"))
  
    plot_batch(wdid,alias, "histoire", "etablissements",
               c('séparé_de', 'absorbé_par', 'prédécesseur'), depth=10,
               node_label = "alias_date",
               edge_label = TRUE)
    
    plot_batch(wdid,alias, "composition", "etablissements",
               c('composante'), depth=10,
               active_only = TRUE,
               append_logfile = TRUE)
  
    plot_batch(wdid,alias, "associations", "etablissements",
               c('composante_de','affilié_à','associé','associé_de'), depth=5,
               active_only = TRUE,
               append_logfile = TRUE)
  }
}



print_to_md("## Regroupements")

# Lecture des id wikidata des racines pour les regroupements, puis plot.
regroupements <- read.csv2("regroupements.csv")
for(i in 1:nrow(regroupements)) {
  wdid <- regroupements[i,1]
  alias <- regroupements[i,2]
  
  plot_batch(wdid,alias, "histoire", "regroupements",
             c('séparé_de', 'absorbé_par', 'prédécesseur'), depth=10,
             node_label = "alias_date",
             edge_label = TRUE)
  
  plot_batch(wdid,alias, "regroupement-court", "regroupements",
             relations = c('composante','associé','affilié_à'), depth = 1,
             append_logfile = TRUE)
  
  plot_batch(wdid,alias, "regroupement-etendu", "regroupements",
             relations = c('composante','associé','affilié_à'), depth = 2,
             append_logfile = TRUE)
  
  plot_batch(wdid,alias, "regroupement-superetendu", "regroupements",
             relations = c('composante','associé','affilié_à'), depth = 10,
             ggs.width = 16, ggs.heigth = 9,
             append_logfile = TRUE)
}


print_to_md("## Histoire des universités historiques")

## Charge les racines et puis plote les graphiques.
anciennes_univ <- read.table("anciennes_univ.csv", sep = ";", header = TRUE, quote="")
for(i in 1:nrow(anciennes_univ))
  plot_batch(anciennes_univ[i,1],anciennes_univ[i,2], "histoire",
             "histoire",
             c('successeur', 'séparé_de', 'absorbé_par', 'composante_de', 'associé_de'), depth=10,
             node_label = "alias_date",
             edge_label = TRUE)



# Enregistre le cache pour éviter d'avoir à retélécharger les données la prochaine fois.
wdesr_save_cache()

