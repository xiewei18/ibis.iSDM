#' @include utils.R waiver.R bdproto.R
NULL

#' @export
if (!methods::isClass("PredictorDataset")) methods::setOldClass("PredictorDataset")
NULL

#' PredictorDataset prototype description
#'
#' @name PredictorDataset-class
#' @aliases PredictorDataset
#' @family bdproto
#' @keywords bdproto
NULL

#' @export
PredictorDataset <- bdproto(
  "PredictorDataset",
  id           = character(0),
  data         = new_waiver(),
  # Printing function
  print = function(self){
    # Getting names and time periods if set
    nn <- name_atomic(self$get_names(), "predictors")
    # Get Time dimension if existing
    tt <- self$get_time()
    if(!(is.Waiver(tt) || is.null(tt))) tt <- paste0(range(tt),collapse = " <> ") else tt <- NULL
    message(paste0(self$name(),':',
                   '\n Name(s):  ',nn,
                   ifelse(!is.null(tt), paste0("\n Timeperiod:  ", tt), "")
                   )
    )
  },
  # Return name
  name = function(self){
    'Predictor dataset'
  },
  # Get Id
  id = function(self){
    self$id
  },
  # Get names of data
  get_names = function(self){
    names(self$get_data())
  },
  # Get data
  get_data = function(self, df = FALSE, na.rm = TRUE, ...){
    if(df) {
      # For SpatRaster
      if(is.Raster(self$data)){
        if(any(is.factor(self$data))){
          # Bugs out for factors, so need
          terra::as.data.frame(self$data, xy = TRUE, na.rm = FALSE, ...)
        } else {
          terra::as.data.frame(self$data, xy = TRUE, na.rm = na.rm, ...)
        }
      } else {
        # For scenario files
        as.data.frame( self$data )
      }
    } else self$data
  },
  # Get time dimension
  get_time = function(self, ...){
    # Get data
    d <- self$get_data()
    if(is.Waiver(d)) return(new_waiver())
    if(!inherits(d, 'stars')){
      # Try and get a z dimension from the raster object
      terra::time(d)
    } else {
      # Get dimensions
      o <- stars::st_dimensions(d)
      # Take third entry as the one likely to be the time variable
      return(
        to_POSIXct(
          stars::st_get_dimension_values(d, names(o)[3], center = TRUE)
        )
      )
    }
  },
  # Get Projection
  get_projection = function(self){
    assertthat::assert_that(is.Raster(self$data) || inherits(self$data,'stars'))
    sf::st_crs(self$data)
  },
  # Get Resolution
  get_resolution = function(self){
    assertthat::assert_that(is.Raster(self$data) || inherits(self$data,'stars'))
    if(is.Raster(self$data)){
      terra::res(self$data)
    } else {
      stars::st_res(self$data)
    }
  },
  # Clip the predictor dataset by another dataset
  crop_data = function(self, pol){
    assertthat::assert_that(is.Raster(self$data) || inherits(self$data,'stars'),
                            inherits(pol, 'sf'),
                            all( unique(sf::st_geometry_type(pol)) %in% c("POLYGON","MULTIPOLYGON") )
                            )
    if(is.Raster(self$data)){
      self$data <- terra::crop(self$data, pol)
    } else {
      # Scenario
      sf::st_crop(self$data, pol)
    }
    invisible()
  },
  # Masking function
  mask = function(self, mask, inverse = FALSE, ...){
    # Check whether prediction has been created
    prediction <- self$get_data(df = FALSE)
    if(!is.Waiver(prediction)){
      # If mask is sf, rasterize
      if(inherits(mask, 'sf')){
        mask <- terra::rasterize(mask, prediction)
      }
      # Check that mask aligns
      if(!terra::compareGeom(prediction, mask)){
        mask <- terra::resample(mask, prediction, method = "near")
      }
      # Now mask and save
      prediction <- terra::mask(prediction, mask, inverse = inverse, ...)

      # Save data
      self$fits[["data"]] <- prediction

      invisible()
    }
  },
  # Add a new Predictor dataset to this collection
  set_data = function(self, x, value){
    assertthat::assert_that(assertthat::is.string(x),
                            is.Raster(value),
                            is_comparable_raster(self$get_data(), value))
    bdproto(NULL, self, data = suppressWarnings( c(self$get_data(), value) ))
  },
  # Remove a specific Predictor by name
  rm_data = function(self, x) {
    assertthat::assert_that(is.vector(x) || is.character(x),
                            all(x %in% names(self$get_data()))
                            )
    # Match indices
    ind <- base::match(x, self$get_names())
    if(is.Raster(self$get_data() )){
      # Overwrite predictor dataset
      if(base::length(ind) == base::length(self$get_names())){
        self$data <- new_waiver()
      } else {
        self$data <- terra::subset(self$get_data(), ind, negate = TRUE)
      }
    } else {
      if(base::length(ind) == base::length(self$get_names())){
        self$data <- new_waiver()
      } else {
      suppressWarnings(
        self$data <- self$data[-ind]
      )
      }
    }
    invisible()
  },
  # Print input messages
  show = function(self) {
    self$print()
  },
  # Collect info statistics with optional decimals
  summary = function(self, digits = 2) {
    # Get data
    d <- self$get_data()
    if(is.Waiver(d)) return(NULL)
    # Need special handling if there any factors
    if(any(is.factor(self$get_data()))){
      out <- self$get_data()[] |> as.data.frame()
      out[,which(is.factor(self$data))] <- factor( out[,which(is.factor(self$data))] ) # Reformat factors variables
      summary(out, digits = digits)
    } else {
      if(inherits(d, 'stars')){
        return(
          summary( as.data.frame(d) )
        )
      } else {
        # Assume raster
        return(
          round(
            terra::summary( d ), digits = digits
          )
        )
      }
    }
    rm(d)
  },
  # Has derivates?
  has_derivates = function(self){
     return(
       base::length( grep("hinge__|bin__|quad__|thresh__", self$get_names() ) ) > 0
     )
  },
  # Number of Predictors in object
  length = function(self) {
    if(inherits(self$get_data(),'SpatRaster'))
      terra::nlyr(self$get_data())
    else
      base::length(self$get_data())
  },
  # Basic Plotting function
  plot = function(self){
    # Plot the predictors
    par.ori <- graphics::par(no.readonly = TRUE)
    if(is.Raster(self$data)){
      terra::plot( self$data, col = ibis_colours[['viridis_cividis']] )
    } else {
      # Assume stars scenario files
      stars:::plot.stars(self$data, col = ibis_colours[['viridis_cividis']])
    }
    graphics::par(par.ori)
  }
)
