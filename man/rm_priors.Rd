% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_priors.R
\name{rm_priors}
\alias{rm_priors}
\title{Remove existing priors from an existing distribution object}
\usage{
rm_priors(x, names = NULL, ...)

\S4method{rm_priors}{BiodiversityDistribution,ANY}(x,names,...)
}
\arguments{
\item{x}{\link{distribution} (i.e. \code{\linkS4class{BiodiversityDistribution}}) object.}

\item{names}{A \code{\link{vector}} or \code{\link{character}} object for priors to be removed.}

\item{...}{Other parameters passed down}
}
\description{
This function allows to remove priors from an existing
\link{distribution} object. In order to remove a set prior, the name of the
prior has to be specified.
}
\examples{
\dontrun{
 # Add prior
 pp <-  GLMNETPrior("forest")
 x <- distribution(background) |>
  add_priors(pp)
 # Remove again
 x <- x |> rm_priors("forest")
}
}
\seealso{
Other prior: 
\code{\link{BARTPriors}()},
\code{\link{BARTPrior}()},
\code{\link{BREGPriors}()},
\code{\link{BREGPrior}()},
\code{\link{GDBPriors}()},
\code{\link{GDBPrior}()},
\code{\link{GLMNETPriors}()},
\code{\link{GLMNETPrior}()},
\code{\link{INLAPriors}()},
\code{\link{INLAPrior}()},
\code{\link{STANPriors}()},
\code{\link{STANPrior}()},
\code{\link{XGBPriors}()},
\code{\link{XGBPrior}()},
\code{\link{add_priors}()},
\code{\link{get_priors}()},
\code{\link{priors}()}
}
\concept{prior}
