makeEMOAIndicator = function(
  fun,
  minimize,
  #type,
  name,
  latex.name) {
  assertFunction(fun, args = "points")
  assertFlag(minimize)
  #assertChoice(type, choices = c("binary", "unary"))
  assertString(name)
  assertString(latex.name)

  fun = BBmisc::setAttribute(fun, "minimize", minimize)
  #fun = BBmisc::setAttribute(fun, "type", type)
  fun = BBmisc::setAttribute(fun, "name", name)
  fun = BBmisc::setAttribute(fun, "latex.name", latex.name)
  fun = BBmisc::addClasses(fun, "ecr_emoa_indicator")
  return(fun)
}

#' @title
#' EMOA performance indicators
#'
#' @description
#' Functions for the computation of unary and binary measures which
#' are useful for the evaluation of the performace of EMOAs. See the references
#' section for literature on these indicators.
#'
#' Given a set of points \code{points}, \code{emoaIndEps} computes the
#' unary epsilon-indicator provided a set of reference points \code{ref.points}.
#'
#' The \code{emoaIndHV} function computes the hypervolume indicator
#' Hyp(X, R, r). Given a set of point X (\code{points}), another set of reference
#' points R (\code{ref.points}) (which maybe the true Pareto front) and a reference
#' point r (\code{ref.point}) it is defined as Hyp(X, R, r) = HV(R, r) - HV(X, r).
#'
#' @param points [\code{matrix}]\cr
#'   Matrix of points.
#' @param ref.points [\code{matrix}]\cr
#'   Set of reference points.
#' @param ref.point [\code{numeric}]\cr
#'   A single reference point used, e.g., for the computation of the hypervolume
#'   indicator via \code{emoaIndHV}. If \code{NULL} the
#'   nadir point of the union of the \code{points} and \code{ref.points} is used.
#' @param ideal.point [\code{numeric}]\cr
#'   The utopia point of the true Pareto front, i.e., each component of the point
#'   contains the best value if the other objectives are neglected.
#' @param nadir.point [\code{numeric}]\cr
#'   Nadir point of the true Pareto front.
#' @param lambda [\code{integer(1)}]\cr
#'   Number of weight vectors to use in estimating the utility function.
#' @param utility [\code{character(1)}]\cr
#'   Name of the utility function to use. Must be one of \dQuote{weightedsum},
#'   \dQuote{tschebycheff} or \dQuote{augmented tschbycheff}.
#' @param ... [any]\cr
#'   Not used at the moment.
#' @return [\code{numeric(1)}] Epsilon indicator.
#' @rdname emoa_indicators
#' @family EMOA performance assessment tools
#' @export
emoaIndEps = makeEMOAIndicator(
  fun = function(points, ref.points, ...) {
    # sanity checks
    assertMatrix(points, mode = "numeric", any.missing = FALSE, all.missing = FALSE)
    assertMatrix(ref.points, mode = "numeric", any.missing = FALSE, all.missing = FALSE)
    assertSameDimensions(points, ref.points)

    return(.Call("emoaIndEpsC", points, ref.points))
  },
  name = "EPS",
  latex.name = "I_{\\\\epsilon}",
  minimize = TRUE
)

#' @rdname emoa_indicators
#' @export
emoaIndHV = makeEMOAIndicator(
  fun = function(points, ref.points, ref.point = NULL, ...) {
    # compute nadir point
    if (is.null(ref.point))
      ref.point = approximateNadirPoint(points, ref.points)

    # sanity checks
    assertMatrix(points, mode = "numeric", any.missing = FALSE, all.missing = FALSE)
    assertMatrix(ref.points, mode = "numeric", any.missing = FALSE, all.missing = FALSE)
    assertNumeric(ref.point, any.missing = FALSE, all.missing = FALSE)
    assertSameDimensions(points, ref.points, ref.point)

    # actual indicator calculation
    hv.points = computeHV(points, ref.point)
    hv.ref.points = computeHV(ref.points, ref.point)

    return (hv.ref.points - hv.points)
  },
  name = "HV",
  latex.name = "I_{HV}",
  minimize = TRUE
)

#' @rdname emoa_indicators
#' @export
emoaIndR1 = makeEMOAIndicator(
  fun = function(points, ref.points, ideal.point = NULL,
    nadir.point = NULL, lambda = NULL, utility = "tschebycheff", ...) {
    computeRIndicator(points, ref.points, ideal.point, nadir.point, lambda, utility,
      aggregator = function(ua, ur) mean(ua > ur) + mean(ua == ur) / 2, ...)
  },
  name = "R1",
  latex.name = "I_{R1}",
  minimize = TRUE
)

#' @rdname emoa_indicators
#' @export
emoaIndR2 = makeEMOAIndicator(
  fun = function(points, ref.points, ideal.point = NULL,
    nadir.point = NULL, lambda = NULL, utility = "tschebycheff", ...) {
    computeRIndicator(points, ref.points, ideal.point, nadir.point, lambda, utility,
      aggregator = function(ua, ur) mean(ur - ua), ...)
  },
  name = "R2",
  latex.name = "I_{R2}",
  minimize = TRUE
)

#' @rdname emoa_indicators
#' @export
emoaIndR3 = makeEMOAIndicator(
  fun = function(points, ref.points, ideal.point = NULL,
    nadir.point = NULL, lambda = NULL, utility = "tschebycheff", ...) {
    computeRIndicator(points, ref.points, ideal.point, nadir.point, lambda, utility,
      aggregator = function(ua, ur) mean((ur - ua) / ur), ...)
  },
  name = "R3",
  latex.name = "I_{R3}",
  minimize = TRUE
)

# @rdname emoa_indicators
computeRIndicator = function(
  points, ref.points,
  ideal.point = NULL, nadir.point = NULL,
  lambda = NULL,
  utility,
  aggregator,
  ...) {
  assertMatrix(points, mode = "numeric", any.missing = FALSE, all.missing = FALSE)
  assertMatrix(ref.points, mode = "numeric", any.missing = FALSE, all.missing = FALSE)
  if (is.null(ideal.point)) {
    ideal.point = approximateIdealPoint(points, ref.points)
  }
  assertNumeric(ideal.point, any.missing = FALSE, all.missing = FALSE)
  utilities = c("weightedsum", "tschebycheff", "augmented tschbycheff")
  assertChoice(utility, utilities)
  assertFunction(aggregator)

  # convert utility to integer index which is used by the C code
  utility = which((match.arg(utility, utilities)) == utilities)
  utility = as.integer(utility)

  n.obj = nrow(points)

  if (is.null(ideal.point)) {
    ideal.point = approximateIdealPoint(points, ref.points)
  }
  if (is.null(nadir.point)) {
    nadir.point = approximateNadirPoint(points, ref.points)
  }

  assertSameDimensions(points, ref.points, ideal.point, nadir.point)

  if (is.null(lambda)) {
    lambda = determineLambdaByDimension(n.obj)
  }
  lambda = convertInteger(lambda)

  ind.points = .Call("computeRIndicatorC", points, ideal.point, nadir.point, lambda, utility)
  ind.ref.points = .Call("computeRIndicatorC", ref.points, ideal.point, nadir.point, lambda, utility)

  ind = aggregator(ind.points, ind.ref.points)

  return (ind)
}

determineLambdaByDimension = function(n.obj) {
  if (n.obj == 2) {
    500L
  } else if (n.obj == 3) {
    30L
  } else if (n.obj == 4) {
    12L
  } else if (n.obj == 5) {
    8L
  } else {
    3L
  }
}

#' @rdname emoa_indicators
#' @export
# Minimum distance between two solutions
emoaIndMD = makeEMOAIndicator(
  fun = function(points, ...) {
    dists = dist(t(points), ...)
    min(dists)
  },
  name = "MD",
  latex.name = "I_{MD}",
  minimize = TRUE
)

# C(A, B) correponds to the ratio of points in B which are dominated by
# at least one solution in A.
emoaIndC = makeEMOAIndicator(
  fun = function(points, ref.points, ...) {
    res = apply(ref.points, 2L, function(pb) {
      any(apply(points, 2L, function(pa) {
        dominates(pa, pb)
      }))
    })
    mean(res)
  },
  name = "C",
  latex.name = "I_{C}",
  minimize = FALSE
)


# M1(A, B) computes the average Euclidean distance between a set of
# points and a reference set
#' @rdname emoa_indicators
#' @export
emoaIndM1 = makeEMOAIndicator(
  fun = function(points, ref.points, ...) {
    dists = apply(points, 2L, function(p) {
      colSums((ref.points - p)^2)
    })
    mean(dists)
  },
  name = "M1",
  latex.name = "I_{M1}",
  minimize = TRUE
)

# Overall non-dominated vector generation
#' @rdname emoa_indicators
#' @export
emoaIndONVG = makeEMOAIndicator(
  fun = function(points, ...) {
    sum(nondominated(points))
  },
  name = "ONVG",
  latex.name = "I_{\\text{ONVG}}",
  minimize = FALSE
)

#' @inheritParams computeGenerationalDistance
#' @rdname emoa_indicators
#' @export
emoaIndGD = makeEMOAIndicator(
  fun = function(points, ref.points, p = 1, normalize = FALSE, dist.fun = computeEuclideanDistance, ...) {
    computeGenerationalDistance(points, ref.points, p = p, normalize = normalize, dist.fun = dist.fun)
  },
  name = "GD",
  latex.name = "I_{GD}",
  minimize = TRUE
)

# Spacing as proposed by Sch95
emoaIndSP = makeEMOAIndicator(
  fun = function(points, ...) {
    n = ncol(points)
    if (n == 1L)
      return(NA)
    dists = as.matrix(dist(t(points), method = "manhattan", p = 1))
    diag(dists) = Inf
    min.dists = apply(dists, 1L, min)
    avg.min.dist = mean(min.dists)
    ind = sqrt(sum((min.dists - avg.min.dist)^2) / (n - 1L))
    return(ind)
  },
  name = "SP",
  latex.name = "I_{SP}",
  minimize = TRUE
)

# \Delta^{'} as proposed by Deb et al. a fast elitist non-dominated ...
emoaIndDelta = makeEMOAIndicator(
  fun = function(points, ...) {
    n = ncol(points)
    if (n == 1L)
      return(NA)
    if (nrow(points) > 2L)
      stopf("emoaIndDelta: only applicable for 2 objectives.")
    # sort points by first objective => sorted in decreasing order
    # regarding second objective automatically
    points = points[, order(points[1L, ], decreasing = FALSE)]

    # compute Euclidean distance between neighbour points
    dists = sapply(1:(n - 1L), function(i) {
      sqrt(sum((points[, i] - points[, i + 1L])^2))
    })
    avg.dist = mean(dists)

    # compute indicator
    mean(abs(dists - avg.dist))
  },
  name = "DELTA",
  latex.name = "I_{\\\\Delta}",
  minimize = TRUE
)

