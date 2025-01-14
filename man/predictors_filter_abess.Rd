% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-predictors.R
\name{predictors_filter_abess}
\alias{predictors_filter_abess}
\alias{predictor_filter_abess}
\title{Apply the adaptive best subset selection framework on a set of predictors}
\usage{
predictors_filter_abess(
  env,
  observed,
  method,
  family,
  tune.type = "cv",
  lambda = 0,
  weight = NULL,
  keep = NULL,
  ...
)
}
\arguments{
\item{env}{A \code{\link{data.frame}} or \code{\link{matrix}} with extracted environmental
covariates for a given species.}

\item{observed}{A \code{\link{vector}} with observational records to use for
determining variable importance.}

\item{method}{Which method to use for constructing the correlation matrix
(Options: \code{'pearson'} (Default), \code{'spearman'}| \code{'kendal'}),
\code{"abess"}, or \code{"boruta"}.}

\item{family}{A \code{\link{character}} indicating the family the observational data
originates from.}

\item{tune.type}{\code{\link{character}} indicating the type used for subset
evaluation. Options are \code{c("gic", "ebic", "bic", "aic", "cv")} as
listed in \code{abess}.}

\item{lambda}{A \code{\link{numeric}} single lambda value for regularized best subset
selection (Default: \code{0}).}

\item{weight}{Observation weights. When weight = \code{NULL}, we set weight =
\code{1} for each observation as default.}

\item{keep}{A \code{\link{vector}} with variables to keep regardless. These are usually
variables for which prior information is known.}

\item{...}{Other options for a specific method}
}
\value{
A \code{\link{vector}} of variable names to exclude
}
\description{
This is a wrapper function to fit the adaptive subset selection
procedure outlined in Zhu et al. (2021) and Zhu et al. (2020).
}
\references{
\itemize{
\item abess: A Fast Best Subset Selection Library in Python and R. Jin Zhu, Liyuan Hu, Junhao Huang, Kangkang Jiang, Yanhang Zhang, Shiyun Lin, Junxian Zhu, Xueqin Wang (2021). arXiv preprint arXiv:2110.09697.
\item A polynomial algorithm for best-subset selection problem. Junxian Zhu, Canhong Wen, Jin Zhu, Heping Zhang, Xueqin Wang. Proceedings of the National Academy of Sciences Dec 2020, 117 (52) 33117-33123; doi: 10.1073/pnas.2014241117
}
}
\keyword{internal}
\keyword{utils,}
