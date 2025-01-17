% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/PA.EMOA.indicators.R
\name{emoaIndEps}
\alias{emoaIndEps}
\alias{emoaIndHV}
\alias{emoaIndR1}
\alias{emoaIndR2}
\alias{emoaIndR3}
\alias{emoaIndMD}
\alias{emoaIndM1}
\alias{emoaIndONVG}
\alias{emoaIndGD}
\title{EMOA performance indicators}
\usage{
emoaIndEps(points, ref.points, ...)

emoaIndHV(points, ref.points, ref.point = NULL, ...)

emoaIndR1(points, ref.points, ideal.point = NULL, nadir.point = NULL,
  lambda = NULL, utility = "tschebycheff", ...)

emoaIndR2(points, ref.points, ideal.point = NULL, nadir.point = NULL,
  lambda = NULL, utility = "tschebycheff", ...)

emoaIndR3(points, ref.points, ideal.point = NULL, nadir.point = NULL,
  lambda = NULL, utility = "tschebycheff", ...)

emoaIndMD(points, ...)

emoaIndM1(points, ref.points, ...)

emoaIndONVG(points, ...)

emoaIndGD(points, ref.points, p = 1, normalize = FALSE,
  dist.fun = computeEuclideanDistance, ...)
}
\arguments{
\item{points}{[\code{matrix}]\cr
Matrix of points.}

\item{ref.points}{[\code{matrix}]\cr
Set of reference points.}

\item{...}{[any]\cr
Not used at the moment.}

\item{ref.point}{[\code{numeric}]\cr
A single reference point used, e.g., for the computation of the hypervolume
indicator via \code{emoaIndHV}. If \code{NULL} the
nadir point of the union of the \code{points} and \code{ref.points} is used.}

\item{ideal.point}{[\code{numeric}]\cr
The utopia point of the true Pareto front, i.e., each component of the point
contains the best value if the other objectives are neglected.}

\item{nadir.point}{[\code{numeric}]\cr
Nadir point of the true Pareto front.}

\item{lambda}{[\code{integer(1)}]\cr
Number of weight vectors to use in estimating the utility function.}

\item{utility}{[\code{character(1)}]\cr
Name of the utility function to use. Must be one of \dQuote{weightedsum},
\dQuote{tschebycheff} or \dQuote{augmented tschbycheff}.}

\item{p}{[\code{numeric(1)}]\cr
Parameter p of the average Hausdoff metric.
Default is 1.}

\item{normalize}{[\code{logical(1)}]\cr
Should the front be normalized on basis of \code{B}?
Default is \code{FALSE}.}

\item{dist.fun}{[\code{matrix}]\cr
Distance function to compute distance between points x and y. Expects a single
numeric vector d with the coordinate-wise differences di = (xi - yi).
Default is \code{computeEuclideanDist}.}
}
\value{
[\code{numeric(1)}] Epsilon indicator.
}
\description{
Functions for the computation of unary and binary measures which
are useful for the evaluation of the performace of EMOAs. See the references
section for literature on these indicators.

Given a set of points \code{points}, \code{emoaIndEps} computes the
unary epsilon-indicator provided a set of reference points \code{ref.points}.

The \code{emoaIndHV} function computes the hypervolume indicator
Hyp(X, R, r). Given a set of point X (\code{points}), another set of reference
points R (\code{ref.points}) (which maybe the true Pareto front) and a reference
point r (\code{ref.point}) it is defined as Hyp(X, R, r) = HV(R, r) - HV(X, r).
}
\seealso{
Other EMOA performance assessment tools: \code{\link{approximateNadirPoint}},
  \code{\link{computeDominanceRanking}},
  \code{\link{makeEMOAIndicator}},
  \code{\link{niceCellFormater}}, \code{\link{normalize}},
  \code{\link{plotDistribution}}, \code{\link{plotFront}},
  \code{\link{plotScatter2d}}, \code{\link{plotScatter3d}},
  \code{\link{toLatex}}
}
\concept{EMOA performance assessment tools}
