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


#' Status of french ESR institutions.
#'
#' A dataset containing the main status (_statuts_) french ESR institutions,
#' together with some additionnal informations.
#'
#' @format A data frame with 6 variables:
#' - id: the wikipedia id of the item;
#' - libellé: the label of the item;
#' - recommandé: whether this item is recommanded to use ("oui") or not ("non");
#' - niveau: level of the item (see \code{\link{wdesr.niveaux}})
#' - wikipedia: url to the wikipedia notice;
#' - note: note to help the user.
#' @source \url{https://www.wikidata.org}
"wdesr.statuts"


#' Levels of french ESR institution status.
#'
#' A dataset containing arbitrary levels to institutions statuts.
#' Used to set sizes when plotting things.
#'niveau;label;description;exemple

#' @format A data frame with 4 variables:
#' - niveau: an integer to id the level;
#' - libellé: the label of the level;
#' - description: a description of the level;
#' - exemple: some example of status of this level.
"wdesr.statuts"



#' Maintainance function to build local cache and datasets
#'
#' @return nothing
#'
#' @examples wdesr_make_package_data()
#' @noRd
wdesr_make_package_data <- function() {
  wdesr.statuts <- read.table("wdesr.statuts.csv",header=TRUE,sep=';',quote='"',stringsAsFactors=FALSE)
  wdesr.niveaux <- read.table("wdesr.niveaux.csv",header=TRUE,sep=';',quote='"',stringsAsFactors=FALSE)
  usethis::use_data(wdesr.statuts, wdesr.niveaux, overwrite = TRUE, internal = FALSE)

  write.table(wdesr.statuts, file = "wdesr.statuts.csv", sep=';', quote = TRUE, row.names = FALSE)
  write.table(wdesr.niveaux, file = "wdesr.niveaux.csv", sep=';', quote = TRUE, row.names = FALSE)

  #usethis::use_data(items,instance_ofs, internal = TRUE, overwrite = TRUE)
}


#' Clear the local WDESR cache.
#'
#' To improve the performances, wikidata items are cached.
#' Must be used whenever the data of wikidata are modified during a R session.
#'
#' @return The WDESR cache.
#' @export
#'
#' @examples wdesr_clear_cache()
#'
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' @seealso
#' - \code{\link{wdesr_get_cache}}
#' - \code{\link{wdesr_save_cache}}
#' - \code{\link{wdesr_load_cache}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
wdesr_clear_cache <- function() {

  wdesr.cache$status <- wikidataESR::wdesr.statuts
  wdesr.cache$items <- data.frame()

  return(wdesr.cache)
}

#' Get the cache.
#'
#' To improve the performances, wikidata items are cached.
#' This function returns this cache.
#' It contains two dataframes: instance_ofs and items.
#'
#' @return The WDESR cache.
#' @export
#'
#' @examples
#' wdesr.cache <- wdesr_get_cache()
#' wdesr.cache$status
#' wdesr.cache$items
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' @seealso
#' - \code{\link{wdesr_clear_cache}}
#' - \code{\link{wdesr_save_cache}}
#' - \code{\link{wdesr_load_cache}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
wdesr_get_cache <- function() {
  return(wdesr.cache)
}


#' Save the cache.
#'
#' To improve the performances, wikidata items are cached.
#' This function saves this cache on the local drive
#'
#' @param file The name of the file to save the cache to (default to "wdesr-cache.RData").
#'
#' @return nothing
#' @export
#'
#' @examples wdesr_save_cache()
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' @seealso
#' - \code{\link{wdesr_clear_cache}}
#' - \code{\link{wdesr_get_cache}}
#' - \code{\link{wdesr_load_cache}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#'
wdesr_save_cache <- function(file = "wdesr-cache.RData") {
  save(status, items, envir = wdesr.cache, file = file)
}


#' Load the cache.
#'
#' To improve the performances, wikidata items are cached.
#' This function loads this cache.
#'
#' @param file The name of the file to read the cache from (default to "wdesr-cache.RData").
#' @param package_statuts TRUE to load the status (_statuts_) cache embeded within the package instead of the local cache (default to FALSE).
#'    Usefull whenever status embeded within the package have been updated.
#'
#' @return the environment of the cache
#' @export
#'
#' @examples wdesr_load_cache()
#' @references
#' - \url{https://github.com/juliengossa/DataESR/tree/master/etablissements.esr/wikidataESR}
#' @seealso
#' - \code{\link{wdesr_clear_cache}}
#' - \code{\link{wdesr_get_cache}}
#' - \code{\link{wdesr_load_cache}}
#' @author Julien Gossa, \email{gossa@unistra.fr}
#'
wdesr_load_cache <- function(file = "wdesr-cache.RData", package_statuts = FALSE) {

  load(file = "wdesr-cache.RData", envir = wdesr.cache )

  if (package_statuts) {
    wdesr.cache$status <- wdesr.statuts
  }
  return(wdesr.cache)
}

# Creating an empty cache.
wdesr.cache <- new.env()
