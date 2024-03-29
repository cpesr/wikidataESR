% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cache.R
\name{wdesr_get_cache}
\alias{wdesr_get_cache}
\title{Get the cache.}
\usage{
wdesr_get_cache()
}
\value{
The WDESR cache.
}
\description{
To improve the performances, wikidata items are cached.
This function returns this cache.
It contains two dataframes: instance_ofs and items.
}
\examples{
wdesr.cache <- wdesr_get_cache()
wdesr.cache$status
wdesr.cache$items
}
\references{
\itemize{
\item \url{https://github.com/cpesr/wikidataESR}
}
}
\seealso{
\itemize{
\item \code{\link{wdesr_clear_cache}}
\item \code{\link{wdesr_get_cache}}
\item \code{\link{wdesr_save_cache}}
\item \code{\link{wdesr_load_cache}}
\item \code{\link{wdesr_remove_from_cache}}
}
}
\author{
Julien Gossa, \email{gossa@unistra.fr}
}
