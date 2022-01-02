library(wikidataESR)

library(ggplot2)
library(network)
library(ggnetwork)
library(scales)
library(dplyr)

wdesr_load_cache()
wdesr_load_and_plot("Q157575",c('composante','associé'),depth=3, active_only = TRUE,
                    size = 1.5,
                    node_size = c(5,20), label_sizes = c(2,5), arrow_gap = 0.06,
                    node_label = "alias", node_type = "text",
                    edge_label = FALSE,
                    edge_arrow = FALSE)
wdesr_save_cache()

wdesr_load_and_plot("Q109409389", c('composante','associé','affilié_à'), depth = 2)

