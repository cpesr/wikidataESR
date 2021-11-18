library(wikidataESR)

library(ggplot2)
library(network)
library(ggnetwork)
library(scales)
library(dplyr)


wdesr_load_and_plot("Q109409389",c('composante','associé'),depth=3, active_only = TRUE,
                    node_size = c(5,20), label_sizes = c(2,5), arrow_gap = 0.06,
                    node_label = "alias", node_type = "text",
                    edge_label = FALSE)

wdesr_load_and_plot("Q999763", c('séparé_de', 'absorbé_par', 'prédécesseur'), depth=10,
                    node_label = "alias_date",
                    edge_label = TRUE)
