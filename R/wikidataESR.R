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


#' wikidataESR: A package for retrieving and plotting ESR data from wikidata.
#'
#' Wikidata is a convenient tool to model universities information.
#' This package intends to help using data about the french universities,
#' namely Enseignement Supérieur et Recherche (ESR).
#' Its main purpose is to plot graphs about ESR universities relationship.
#'
#' @docType package
#' @name wikidataESR
#'
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' - \url{https://www.wikidata.org}
#'
#' @author Julien Gossa, \email{gossa@unistra.fr}
NULL


#' Get the ESR status of a wikidata item
#'
#' The status (_statut_) is the _legal status_ of an ESR institution.
#' It is based on the instance_of property (P31) and converted thanks to a local dataset.
#'
#' @param item A wikidata item, as returned by wikidataR.
#'
#' @return The status the item.
#'
#' @examples
#' wdesr_get_item_status(item)
#'
#' @references \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' @seealso \code{\link{wdesr.statuts}}, \code{\link[WikidataR]{WikidataR}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#' @noRd
wdesr_get_item_status <- function(item) {
  item_id <- item[[1]]$id
  instance_of_id <- wd_get_item_statement_as_list(item,"P31")[[1]][[1]]
  if(is.null(instance_of_id)) {
    warning("The instance of wikidata item ", item_id, " is not set.\n",
            "  Default level (size of the node) is set to 7.\n",
            "  Please check the property P31 at https://www.wikidata.org/wiki/",item_id,"\n",
            "  using the guideline at https://github.com/juliengossa/DataESR/tree/master/etablissements.esr")

    instance_of_id <- "NOID"
  }

  if (!instance_of_id %in% wdesr.cache$status$id) {
    it <- WikidataR::get_item(id = instance_of_id)
    label <- wd_get_item_alias(it)

    warning("The instance of wikidata item ", item_id, " is unknown by wikidataESR: ",label,".\n",
            "  Default level (size of the node) is set to 4.\n",
            "  Please check the property P31 at https://www.wikidata.org/wiki/",item_id,"\n",
            "  using the guideline at https://github.com/juliengossa/DataESR/tree/master/etablissements.esr")

    wdesr.cache$status <- rbind(
      wdesr.cache$status,
      c(id         = instance_of_id,
        libellé    = label,
        recommandé = "",
        niveau     = 5,
        wikipedia  = "",
        note       = "statut inexistant dans la base wikidataESR"))
  }

  status <- subset(wdesr.cache$status, id == instance_of_id)

  if (status$recommandé == "non")
    warning("The instance of wikidata item ", item_id, " is not recommended: ",status$libellé,".\n",
            "  Reason is: ", ifelse(status$note != "",status$note, "Statut pas assez précis"),".\n",
            "  Please check https://www.wikidata.org/wiki/",item_id,"\n",
            "  using the guideline at https://github.com/juliengossa/DataESR/tree/master/etablissements.esr")

  return(status)
}



#' Load the data of one university.
#'
#' @param wdid The wikidata id of the university.
#'
#' @return A dataframe with the data of the university.
#'
#' @examples wdesr_load_item("Q3551576")
#'
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' - \url{https://www.wikidata.org}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#' @noRd
wdesr_load_item <- function(wdid) {

  item <- WikidataR::get_item(id = wdid)
  status <- wdesr_get_item_status(item)

  return(
    data.frame(
      id          = wdid,
      label       = wd_get_item_label(item),
      alias       = wd_get_item_alias(item),
      statut      = status$libellé,
      niveau      = status$niveau,

      fondation   = wd_get_item_statement_as_year(item,"P571"),
      dissolution = wd_get_item_statement_as_year(item,"P576"),

      associé      = wd_get_item_statement_as_list(item,"P527"),
      associé_de   = wd_get_item_statement_as_list(item,"P361"),

      composante    = wd_get_item_statement_as_list(item,"P355"),
      composante_de = wd_get_item_statement_as_list(item,"P749"),

      prédécesseur     = wd_get_item_statement_as_list(item,"P1365"),
      prédécesseur_pit = wd_get_item_statement_qualifier_as_list(item,"P1365","P585"),
      successeur       = wd_get_item_statement_as_list(item,"P1366"),
      successeur_pit   = wd_get_item_statement_qualifier_as_list(item,"P1366","P585"),

      séparé_de        = wd_get_item_statement_as_list(item,"P807"),
      séparé_de_pit    = wd_get_item_statement_qualifier_as_list(item,"P807","P585"),

      membre_de = wd_get_item_statement_as_list(item,"P463")
    )
  )
}

#' Load the data of a set of universities.
#'
#' @param wdids A set of wikidata ids.
#'
#' @return A dataframe with the data of the universities.
#'
#' @examples wdesr_load_items(c("Q3551576","Q2013017"))
#'
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' - \url{https://www.wikidata.org}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#' @noRd
wdesr_load_items <- function(wdids) {
  for(subids in wdids) {
    for(wdid in subids) {
      print(paste("Loading: ",wdid))
      r <- wdesr_load_item(wdid)
      wdesr.cache$items <- rbind(wdesr.cache$items,r)
    }
  }
}

#' Loader of universities data.
#'
#' Get the data of a set of universities.
#'
#' Data are cached: use \code{\link{wdesr_clear_cache}} to refresh data from wikidata.
#'
#' @param wdids A set of wikidata ids.
#'
#' @return A dataframe with the data of the universities.
#' @export
#'
#' @examples items <- wdesr_get_data(c("Q3551576","Q2013017"))
#'
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' - \url{https://www.wikidata.org}
#' @seealso \code{\link{wdesr_clear_cache}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
wdesr_get_data <- function(wdids) {
  if (is.null(wdesr.cache$status)) {
    wdesr_clear_cache()
  }

  wdesr_load_items(wdids[! wdids %in% wdesr.cache$items$id])

  return(subset(wdesr.cache$items, id %in% wdids))
}


#' Get a graph of universities.
#'
#' From a root wikipedia id, the function follows a given set of properties,
#' building vertice and edges along the way.
#'
#' Data are cached: use \code{\link{wdesr_clear_cache}} to refresh data from wikidata.
#'
#' @param wdid The wikidata id of the root.
#' @param props The set of properties to follow.
#' @param depth The depth of the graph (more or less) (default to 3).
#' @param active_only TRUE to filter dissolved universities (default to FALSE).
#' @param stop_at A list of type of nodes that must not be visited furthermore (default to "EPST").
#'
#' @return A list of edges and vertices.
#' @export
#'
#' @examples
#' g <- wdesr_get_graph("Q61716176",c('composante','associé'), 1)
#' g$edges
#' g$vertice
#'
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' - \url{https://www.wikidata.org}
#' @seealso \code{\link{wdesr_clear_cache}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
wdesr_get_graph <- function(wdid, props, depth = 3, active_only = FALSE, stop_at = c("EPST") ) {

  wgge <- new.env()
  wgge$edges <- data.frame(from=character(),to=character(),stringsAsFactors = FALSE)
  wgge$vertices <- data.frame()

  wdesr_get_subgraph(wgge, wdid, props, depth, active_only, stop_at)

  wgge$vertices <- wgge$vertices %>% mutate_all(as.character) %>% arrange(id)
  #wgge$vertices$niveau <- factor(wgge$vertices$niveau, levels = wdesr.niveaux$niveau)

  res <- list('edges'=wgge$edges, 'vertices'=wgge$vertices)

  return(res)
}

#' Get a sub graph of universities.
#' @return A list of edges and vertices.
#' @noRd
#'
#' @seealso \code{\link{wdesr_get_graph}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
wdesr_get_subgraph <- function(wgge, wdid, props, depth = 3, active_only = FALSE, stop_at = c("EPST") ) {

  df.from <- wdesr_get_data(c(wdid))

  #df.from$depth <- depth
  wgge$vertices <- rbind(wgge$vertices, df.from)

  #print(wdid)
  #print(wgge$vertices$id)
  #print(wgge$vertices[,1:2])

  for(p in props) {
    if(is.null(unlist(df.from[,p])))
      next()

    ppit <- paste(p,'_pit',sep='')

    df.to <- wdesr_get_data(unlist(df.from[,p]))

    # Remove dissolved
    if (active_only) df.to <- subset(df.to, is.na(dissolution))

    # Remove existing to -> from edges
    tmp <- subset(wgge$edges, to == wdid)$from
    df.to <- subset(df.to, !id %in% tmp)

    if (nrow(df.to) == 0) next()

    edges <- data.frame(
      from  = df.from$id,
      to    = df.to$id,
      type  = p,
      date  = ifelse(ppit %in% colnames(df.from),unlist(df.from[,ppit]),NA),
      depth = depth
      )
    wgge$edges <- rbind(wgge$edges,edges)

    #df.to$depth <- depth - 1

    if(depth==1) {
      wgge$vertices <- rbind(wgge$vertices, subset(df.to, !id %in% wgge$vertices$id))
    } else {
      wgge$vertices <- rbind(wgge$vertices, subset(df.to, !id %in% wgge$vertices$id & statut %in% stop_at))

      for(id in subset(df.to, !statut %in% stop_at)$id) {
        if (!id %in% wgge$vertices$id)
          wdesr_get_subgraph(wgge, id,props,depth-1,active_only,stop_at)
      }
    }
  }
}



#' Label builder.
#'
#' Build the label of the nodes.
#'
#' @param node_label Either "alias", "alias_date", "long", or "long_date" (default to "alias").
#' @param alias The alias of the item.
#' @param label The label of the item.
#' @param fondation The foundation date of the item.
#' @param dissolution The dissolution date of the item.
#'
#' @return a label for a node, as a string
#'
#' @examples node_label_aes("alias", alias, label, fondation, dissolution)
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' - \url{https://www.wikidata.org}
#' @seealso \code{\link{wdesr_clear_cache}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#' @noRd
wdesr_node_label_aes <- function(node_label = "alias", alias, label, fondation, dissolution) {
  switch(node_label,
         alias = {
           alias},
         alias_date = {
           paste(alias,paste('(',fondation,'-',dissolution,')',sep=''),sep='\n')},
         long = {
           label},
         long_date = {
           paste(label,paste('(',fondation,'-',dissolution,')',sep=''),sep='\n')},
         ""
  )
}

#' Get geom_nodeX function.
#'
#' Get the suitable geom_nodeX function according the node_type
#'
#' @param node_type Either "text", "text_repel", "label", or "label_repel" (default to "text").
#'
#' @return The suitable geom_nodeX function according the node_type.
#'
#' @examples wdesr_node_geom("text_repel")
#'
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' - \url{https://www.wikidata.org}
#' @seealso \code{\link{wdesr_clear_cache}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#' @noRd
wdesr_node_geom <- function(node_type = "text") {
  switch(node_type,
         text = {geom_nodetext},
         text_repel = {geom_nodetext_repel},
         label = {geom_nodelabel},
         label_repel = {geom_nodelabel_repel},
         geom_blank
  )
}


#' Plot an ESR graph.
#'
#' A wrapper for ggplot2 to plot graph as returned by \code{\link{wdesr_get_graph}}.
#'
#' @param df.g A dataframe representing a graph, as returned by wdesr_get_graph.
#' @param layout The layout to use to plot the graph as in \code{\link[sna]{gplot.layout}}.
#' @param active_only TRUE to filter the dissolved nodes (default to FALSE).
#' @param node_sizes The size of the nodes, either a single value or a range c(min,max).
#' @param label_sizes The size of the nodes, either a single value or a range c(min,max).
#' @param node_label Define the label for the nodess. Either "alias", "alias_date", "long", or "long_date" (default to "alias").
#' @param node_type Define the type of drawing for the nodes. Either "text", "text_repel", "label", or "label_repel" (default to "text").
#' @param edge_label TRUE to plot dates on edges (default to "TRUE").
#' @param arrow_gap A parameter that will shorten the network edges in order to avoid overplotting edge arrows and nodes see \code{\link[ggnetwork]{fortify.network}}.
#' @param size_guide TRUE to plot the guide for sizes (defalut to "FALSE").
#'
#' @return A ggplot2.
#' @export
#'
#' @examples
#' df.aslace <- wdesr_get_graph("Q61716176",c('composante','associé'), 1)
#'
#' wdesr_ggplot_graph(df.alsace,
#'   node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
#'   node_label = "alias", node_type = "text",
#'   edge_label = FALSE)
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' - \url{https://www.wikidata.org}
#' @seealso \code{\link{wdesr_clear_cache}}
#' @author Julien Gossa, \email{gossa@unistra.fr}

wdesr_ggplot_graph <- function( df.g,
                                layout = "kamadakawai",
                                active_only = FALSE,
                                node_sizes = c(10,30),
                                label_sizes = c(4,6),
                                node_label = "alias",
                                node_type = "text",
                                edge_label = TRUE,
                                arrow_gap = 0.05,
                                size_guide = FALSE) {

  if( nrow(df.g$vertices) == 0 | nrow(df.g$edges) == 0 )
    stop("Empty ESR graph: something went wrong with the graph production parameters")

  #df.g$edges$weight <- scales::rescale(as.numeric(df.g$edges$depth),c(1,2))
  geom_node_fun <- wdesr_node_geom(node_type)

  net <<- network::network(df.g$edges,
                           vertex.attr=df.g$vertices,
                           matrix.type="edgelist", ignore.eval=FALSE,
                           directed = TRUE)

  ggnet <<- ggnetwork(net,
                      layout = layout,
                      weights = "weight",
                      radii  = scales::rescale(-as.numeric(df.g$vertices$niveau)),
                      arrow.gap = arrow_gap)

  g <- ggplot(ggnet, aes(x = x, y = y, xend = xend, yend = yend))
  g <- g + geom_edges(aes(linetype = type),#, size = weight),
                      arrow = arrow(length = unit(8, "pt"), type = "closed"),
                      alpha=1,
                      color="darkgrey")

  if(edge_label) g <- g + geom_edgetext(aes(label=date), size = min(label_sizes))

  g <- g + geom_nodes(aes(
    color=statut,
    alpha = (dissolution != "NA"),
    size = factor(niveau, levels=wdesr.niveaux$niveau)  #scales::rescale(-as.numeric(df.g$vertices$niveau),node_sizes)
  ))
  g <- g + geom_node_fun(aes(
    label = wdesr_node_label_aes(node_label,alias,label,fondation,dissolution),
    fill = statut),
    size = scales::rescale(-as.numeric(df.g$vertices$niveau),label_sizes)
    )
  g <- g + scale_alpha_manual(labels=c("dissous","actif"), values = (c(0.6,1)), name='statut')
  g <- g + scale_size_manual(breaks=as.character(wdesr.niveaux$niveau),
                             values=scales::rescale(-as.numeric(wdesr.niveaux$niveau),node_sizes),
                             labels=wdesr.niveaux$libellé,
                             name="niveau",
                             drop=FALSE,
                             guide=ifelse(size_guide,"legend",FALSE))
  g <- g + xlim(-0.2,1.2) + ylim(-0.03,1.03)
  g <- g + theme_blank()

  return(g)
}

# ggplotly_wdesr_graph <- function(df.g) {
#   net <<- network(df.g$edges,
#                   vertex.attr=df.g$vertices %>% mutate_all(as.character) %>% arrange(id),
#                   matrix.type="edgelist", ignore.eval=FALSE)
#
#   ggnet <<- ggnetwork(net, layout = "kamadakawai",directed=TRUE)
#
#   ggplot(ggnet, aes(x = x, y = y, xend = xend, yend = yend)) +
#     geom_edges(aes(color = type, text=paste('date :',date)),
#                arrow = arrow(length = unit(10, "pt"), type = "closed")) +
#     #geom_edgetext(aes(color = type, label=date)) +
#     geom_nodetext(aes(
#       label = alias,
#       text = paste(label,status,paste('(',fondation,'-',dissolution,')',sep=''),paste("wikidata id:",id),sep='\n'),
#       color=status)) +
#     theme_blank()
#
#   ggplotly(tooltip="text")
# }


#' Wrapper to load and plot ESR graphs.
#'
#' Conveniently call \code{\link{wdesr_get_graph}} and then \code{\link{wdesr_ggplot_graph}}.
#'
#' @param wdid The wikidata id of the root.
#' @param props The properties to follows.
#' @param depth The depth of the following
#' @param plot_type Either "ggplot" or "plotly" (default to ggplot).
#' @param ... Additionnal parameters for the plot; see \code{\link{wdesr_ggplot_graph}} for details.
#' @param active_only TRUE to filter dissolved universities (default to FALSE).
#' @return A ggplot or a plotly.
#' @export
#'
#' @examples
#' wdesr_load_and_plot("Q61716176",c('composante','associé'), 1,
#'   node_size = c(10,30), label_sizes = c(3,5), arrow_gap = 0.0,
#'   node_label = "alias", node_type = "text",
#'   edge_label = FALSE)
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' - \url{https://www.wikidata.org}
#' @seealso \code{\link{wdesr_clear_cache}}
#' @author Julien Gossa, \email{gossa@unistra.fr}

wdesr_load_and_plot <- function( wdid,
                                 props          = c('composante','associé'),
                                 depth          = 3,
                                 active_only    = FALSE,
                                 plot_type      = 'ggplot',
                                 ...) {

  df.g <<- wdesr_get_graph(wdid,props,depth,active_only)

  if(plot_type == 'plotly') {
    wdesr_ggplotly_graph(df.g)
  } else {
    wdesr_ggplot_graph(df.g,...)
  }
}

