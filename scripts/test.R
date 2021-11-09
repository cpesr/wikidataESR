library(wikidataESR)

library(ggplot2)
library(network)
library(ggnetwork)
library(scales)
library(dplyr)


wdesr_load_and_plot("Q4173330",c('composante','associé'),depth=2, active_only = TRUE,
                    node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                    node_label = "alias", node_type = "text",
                    edge_label = FALSE)


## Redirections
wdesr_clear_cache()
wikidataESR:::wdesr_load_item("Q80186910")
