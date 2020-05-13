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



#' Get the label of a wikidata item.
#'
#' Look for french first, and return english otherwise.
#'
#' @param item A wikidata item.
#'
#' @return The label of the item.
#'
#' @examples wd_get_item_label(item)
#'
#' @references \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' @seealso \code{\link[WikidataR]{WikidataR}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#' @noRd
wd_get_item_label <- function(item) {
  ifelse(!is.null(item[[1]]$labels$fr$value[[1]]),
         item[[1]]$labels$fr$value[[1]],
         item[[1]]$labels$en$value[[1]])
}

#' Get the alias of a wikidata item.
#'
#' Look for shortest french label/alias first, and return label otherwise.
#'
#' @param item A wikidata item.
#'
#' @return The alias of the item.
#'
#' @examples wd_get_item_alias(item)
#'
#' @references \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' @seealso \code{\link[WikidataR]{WikidataR}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#' @noRd
wd_get_item_alias <- function(item) {
  a <- c(item[[1]]$aliases$fr$value, item[[1]]$labels$fr$value, wd_get_item_label(item))
  return(a[stringr::str_length(a) == min(stringr::str_length(a))][1])
}

#' Get the year from a statement of a wikidata item.
#'
#' (It's very dirty. Sorry.)
#'
#' @param item A wikidata item.
#' @param prop The property to get the year from.
#'
#' @return The year stated in the item.
#'
#' @examples wd_get_item_statement_as_year(item, "P571")
#'
#' @references \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' @seealso \code{\link[WikidataR]{WikidataR}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#' @noRd
wd_get_item_statement_as_year <- function(item,prop) {
  tryCatch(
    date <- item[[1]]$claims[[prop]]$mainsnak$datavalue$value$time[1],
    error = function(e) date<-NULL)

  return(ifelse(is.null(date),NA,substr(as.character.Date(date),2,5)))
}

#' Get the list of statements for a given property.
#'
#' @param item A wikidata item.
#' @param prop The property to get the statements from.
#'
#' @return The list of statements.
#'
#' @examples wd_get_item_statement_as_list(item,"P527")
#'
#' @references \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' @seealso \code{\link[WikidataR]{WikidataR}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#' @noRd
wd_get_item_statement_as_list <- function(item,prop) {
  I(list(item[[1]]$claims[[prop]]$mainsnak$datavalue$value$id))
}

#' Get the qualifiers of statements from a wikidata item.
#'
#' @param item A wikidata item.
#' @param prop The property to get the statements.
#' @param qual The qualifier to retrieve.
#'
#' @return A liste of item statement qualifiers.
#'
#' @examples wd_get_item_statement_qualifier_as_list(item,"P1365","P585")
#'
#' @references \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' @seealso \code{\link[WikidataR]{WikidataR}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#' @noRd
wd_get_item_statement_qualifier_as_list <- function(item,prop,qual) {
  dates <- item[[1]]$claims[[prop]]$qualifiers[[qual]]
  if(is.null(dates)) return(NA)
  l <- unlist(
    lapply(item[[1]]$claims[[prop]]$qualifiers[[qual]],
           function(x) substr(x$datavalue$value$time,2,5)))
  return(I(list(l)))
}

