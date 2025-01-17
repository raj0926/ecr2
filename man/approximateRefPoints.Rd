% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/PA.EMOA.approximateRefPoints.R
\name{approximateRefPoints}
\alias{approximateRefPoints}
\title{Helper function to estimate reference points.}
\usage{
approximateRefPoints(df, obj.cols, offset = 0, as.df = FALSE)
}
\arguments{
\item{df}{[\code{data.frame}]\cr
Data frame with the required structure.}

\item{obj.cols}{[\code{character(>= 2)}]\cr
Column names of the objective functions.
Default is \code{c("f1", "f2")}, i.e., the bi-objective case is assumed.}

\item{offset}{[\code{numeric(1)}]\cr
Offset added to reference points.
Default is \code{0}.}

\item{as.df}{[\code{logical(1)}]\cr
Should a data.frame be returned?
Default is \code{FALSE}. In this case a named list is returned.}
}
\value{
[\code{list} | \code{data.frame}]
}
\description{
E.g., for calculation of dominated hypervolume.
}
\seealso{
Other EMOA performance assessment tools
 @export: \code{\link{approximateRefSets}}
}
\concept{EMOA performance assessment tools
 @export}
