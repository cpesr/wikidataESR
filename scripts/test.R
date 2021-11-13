library(wikidataESR)

library(ggplot2)
library(network)
library(ggnetwork)
library(scales)
library(dplyr)


wdesr_load_and_plot("Q999763",c('composante','associé'),depth=2, active_only = TRUE,
                    node_size = c(10,30), label_sizes = c(3,10), arrow_gap = 0.06,
                    node_label = "alias", node_type = "text",
                    edge_label = FALSE)

wdesr_load_and_plot("Q999763", c('séparé_de', 'absorbé_par', 'prédécesseur'), depth=10,
                    node_label = "alias_date",
                    edge_label = TRUE)

df <- wdesr_get_graph("Q999763", c('séparé_de', 'absorbé_par', 'prédécesseur'), depth=10)


df <- wdesr_get_graph("Q186638", c('composante_de','affilié_à','associé','associé_de'), depth=5)

## Redirections
wdesr_clear_cache()
wikidataESR:::wdesr_load_item("Q80186910")

wdesr_load_and_plot("Q19370961",c('composante','associé'),depth=2, active_only = TRUE,
                    node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
                    node_label = "alias", node_type = "text",
                    edge_label = FALSE)

## Active only

wdesr_get_graph("Q3551755", c('composante_de','affilié_à','associé','associé_de'), depth=5)
wdesr_get_graph("Q3551755", c('composante_de','affilié_à','associé','associé_de'), depth=5,
                      active_only = TRUE)



wdesr_load_and_plot("Q999763",c('composante','associé'),depth=2, active_only = TRUE,
                    node_size = c(10,30), label_sizes = c(3,10), arrow_gap = 0.06,
                    node_label = "alias", node_type = "text",
                    edge_label = FALSE)


## layout igraph

df <- wdesr_get_graph("Q13531686", c('composante'), depth=10)
df$vertices %>% select(id,label,niveau)
df$edges %>% mutate(w = wikidataESR:::distance2weight(distance))

wdesr_ggplot_graph(df)
