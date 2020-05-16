
library(wikidataESR)

library(ggplot2)
library(network)
library(ggnetwork)
library(scales)
library(dplyr)


## Examples 
wdesr_load_cache()
df.alsace <- wdesr_get_graph("Q61716176",c('composante','associé'), 2)
wdesr_save_cache()
wdesr_ggplot_graph(df.alsace,
                   node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                   node_label = "alias", node_type = "text",
                   edge_label = FALSE,
                   size_guide = TRUE)

ggsave(paste("test.png",sep=''), width = 13, height = 8, dpi=150)

wdesr_load_and_plot("Q61716176",c('composante','associé'), 1,
                    node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                    node_label = "alias", node_type = "text",
                    edge_label = FALSE)

wdesr_load_and_plot("Q61716176",c('composante','associé'), 1,
                    node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                    node_label = "alias", node_type = "text",
                    edge_label = FALSE)


wdesr_load_and_plot("Q209842",c('successeur', 'séparé_de', 'composante_de', 'associé_de'), depth=10,
                    node_size = 3, label_sizes = 4, arrow_gap = 0.05,
                    node_label = "alias_date", node_type = "text",
                    edge_label = FALSE)


wdesr_load_and_plot("Q209842",c('successeur', 'séparé_de', 'composante_de', 'associé_de'), depth=10,
                    node_size = 3, label_sizes = 3, arrow_gap = 0.005,
                    node_label = "alias_date", node_type = "text_repel",
                    edge_label = TRUE)

wdesr_load_and_plot("Q209842",c('successeur', 'séparé_de', 'composante_de', 'associé_de'), depth=10,
                    node_size = 15, label_sizes = 3.5, arrow_gap = 0.04,
                    node_label = "alias", node_type = "text",
                    edge_label = TRUE)


## Caches
ios <- wd_get_instance_of_cache()
write.table(ios,"instance_of_cache.csv",sep='\t',row.names = FALSE)

## Atelier

g <- wdesr_get_graph("Q64590454",c('composante','associé'),depth=2, active_only = TRUE)

wdesr_load_and_plot("Q64590454",c('composante','associé'),depth=2, active_only = TRUE,
                    node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                    node_label = "alias", node_type = "text",
                    edge_label = FALSE)



# UCO / UA


g <- wdesr_get_graph("Q1538727",c('successeur', 'séparé_de', 'composante_de', 'associé_de'),depth=2, active_only = TRUE)

wdesr_load_and_plot("Q1538727",c('successeur', 'séparé_de', 'composante_de', 'associé_de'), 1,
                    node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                    node_label = "alias", node_type = "text",
                    edge_label = FALSE)

wdesr_load_and_plot("Q1538727",c('composante','associé'), 1,
                    node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                    node_label = "alias", node_type = "text",
                    edge_label = FALSE)

