#' Generic function to write spatial outputs
#'
#' @description The `write_output` function is a generic wrapper to writing any
#' output files (e.g. projections) created with the [`ibis.iSDM-package`]. It is
#' possible to write outputs of fitted [`DistributionModel`],
#' [`BiodiversityScenario`] or individual [`terra`] or [`stars`] objects. In
#' case a [`data.frame`] is supplied, the output is written as csv file.
#' **For creating summaries of distribution and scenario parameters and performance, see `write_summary()`**
#' @note By default output files will be overwritten if already existing!
#' @param mod Provided [`DistributionModel`], [`BiodiversityScenario`],
#'   [`terra`] or [`stars`] object.
#' @param fname A [`character`] depicting an output filename.
#' @param dt A [`character`] for the output datatype. Following the
#'   [`terra::writeRaster`] options (Default: \code{'FLT4S'}).
#' @param verbose [`logical`] indicating whether messages should be shown.
#'   Overwrites `getOption("ibis.setupmessages")` (Default: \code{TRUE}).
#' @param ... Any other arguments passed on the individual functions.
#' @returns No R-output is created. A file is written to the target direction.
#' @examples \dontrun{
#' x <- distribution(background)  |>
#'  add_biodiversity_poipo(virtual_points, field_occurrence = 'observed', name = 'Virtual points') |>
#'  add_predictors(pred_current, transform = 'scale',derivates = 'none') |>
#'  engine_xgboost(nrounds = 2000) |> train(varsel = FALSE, only_linear = TRUE)
#' write_output(x, "testmodel.tif")
#' }

#' @name write_output
#' @aliases write_output
#' @keywords utils
#' @exportMethod write_output
#' @export
NULL
methods::setGeneric("write_output",
                    signature = methods::signature("mod", "fname"),
                    function(mod, fname, dt = "FLT4S", verbose = getOption("ibis.setupmessages"), ...) standardGeneric("write_output"))

#' @name write_output
#' @rdname write_output
#' @usage
#'   \S4method{write_output}{ANY,character,character,logical}(mod,fname,dt,verbose)
methods::setMethod(
  "write_output",
  methods::signature("ANY", fname = "character"),
  function(mod, fname, dt = "FLT4S", verbose = getOption("ibis.setupmessages"), ...){
    assertthat::assert_that(
      !missing(mod),
      is.character(fname),
      is.character(dt),
      is.logical(verbose)
    )

    if(verbose && getOption('ibis.setupmessages')) myLog('[Output]','green','Saving output(s)...')

    # This function will only capture the distribution model object and will
    # save them separately
    if(any(class(mod) %in% getOption("ibis.engines")) ){
      # FIXME: If errors occur, check harmonization of saving among engines.
      mod$save(fname = fname)
    } else if(is.Raster(mod)){
        if(tools::file_ext(fname) %in% c('tif', 'TIF')) {
          writeGeoTiff(file = mod, fname = fname, dt = dt)
        } else if(tools::file_ext(fname) %in% c('nc', 'NC', 'ncdf', 'NCDF')){
          writeNetCDF(file = mode, fname = fname, varName = names(mod), dt = dt)
        } else {
          stop("Output type could not be determined. Currently only geoTIFF and netCDF are supported.")
        }
    } else if(is.data.frame(mod)){
      utils::write.csv(x = mod,file = fname,...)
    } else {
      # Check that a save function exists for object
      assertthat::assert_that("save" %in%names(mod),
                              msg = "No method to save the output could be found!")
      # Try a generic save
      mod$save(fname = fname)
    }
    invisible()
    }
)

#' @name write_output
#' @rdname write_output
#' @usage
#'   \S4method{write_output}{BiodiversityScenario,character,character,logical}(mod,fname,dt,verbose)
methods::setMethod(
  "write_output",
  methods::signature(mod = "BiodiversityScenario",fname = "character"),
  function(mod, fname, dt = "FLT4S", verbose = getOption("ibis.setupmessages"), ...) {
    assertthat::assert_that(
      !missing(mod),
      is.character(fname),
      is.character(dt),
      is.logical(verbose)
    )
    # Get outputs
    mod$save(fname = fname, type = tools::file_ext(fname), dt = dt)
    invisible()
  }
)

#' @name write_output
#' @rdname write_output
#' @usage
#'   \S4method{write_output}{SpatRaster,character,character,logical}(mod,fname,dt,verbose)
methods::setMethod(
  "write_output",
  methods::signature(mod = "SpatRaster",fname = "character"),
  function(mod, fname, dt = "FLT4S", verbose = getOption("ibis.setupmessages"), ...) {
    assertthat::assert_that(
      !missing(mod),
      is.Raster(mod),
      is.character(fname),
      is.character(dt),
      is.logical(verbose)
    )

    # Write output depending on type
    if(tools::file_ext(fname) %in% c('tif', 'TIF')) {
      writeGeoTiff(file = mod, fname = fname, dt = dt)
    } else if(tools::file_ext(fname) %in% c('nc', 'NC', 'ncdf', 'NCDF')){
      writeNetCDF(file = mode, fname = fname, varName = names(mod), dt = dt)
    } else {
      stop("Output type could not be determined. Currently only geoTIFF and netCDF are supported.")
    }
    invisible()
  }
)

#' @name write_output
#' @rdname write_output
#' @usage
#'   \S4method{write_output}{data.frame,character,character,logical}(mod,fname,dt,verbose)
methods::setMethod(
  "write_output",
  methods::signature(mod = "data.frame",fname = "character"),
  function(mod, fname, dt = "FLT4S", verbose = getOption("ibis.setupmessages"),...) {
    assertthat::assert_that(
      !missing(mod),
      is.data.frame(mod),
      is.character(fname),
      is.logical(verbose)
    )

    # data.frames will be written by default as csv files for consistency
    fname <- paste0( tools::file_path_sans_ext(fname), ".csv")
    utils::write.csv(x = mod, file = fname, ...)
    invisible()
  }
)

#' @name write_output
#' @rdname write_output
#' @usage
#'   \S4method{write_output}{stars,character,character,logical}(mod,fname,dt,verbose)
methods::setMethod(
  "write_output",
  methods::signature(mod = "stars",fname = "character"),
  function(mod, fname, dt = "FLT4S", verbose = getOption("ibis.setupmessages"),...) {
    assertthat::assert_that(
      !missing(mod),
      # is.list(mod),
      is.character(fname),
      is.logical(verbose)
    )
    # Check that it is a star object
    assertthat::assert_that(
      inherits(mod, "stars"), msg = "Supplied list object needs to be a stars object."
    )

    # Define filename
    fname <- paste0( tools::file_path_sans_ext(fname), ".nc")
    # TODO: Align with write NetCDF function further below
    stars::write_stars(
      obj = mod,
      dsn = fname,
      layer = names(mod),
      ...)
    invisible()
  }
)

#' Saves a raster file in Geotiff format
#'
#' @description Functions that acts as a wrapper to [terra::writeRaster].
#' @param file A [`terra`] SpatRaster object to be saved.
#' @param fname A [`character`] stating the output destination.
#' @param dt The datatype to be written (Default: *Float64*).
#' @param varNA The nodata value to be used (Default: \code{-9999}).
#' @param ... Other options.
#' @keywords utils, internal
#' @noRd
writeGeoTiff <- function(file, fname, dt = "FLT4S", varNA = -9999, ...){
  assertthat::assert_that(
    is.Raster(file) || inherits(file, 'stars'),
    is.character(fname), is.character(dt),
    is.numeric(varNA)
  )
  if(!assertthat::has_extension(fname,"tif")) fname <- paste0(fname,".tif")

  # Check if layer is factor and deratify if so (causes error otherwise)
  if(any(is.factor(file))){
    file <- terra::droplevels(file)
  }

  # Save output
  terra::writeRaster(
    x = file,
    filename = fname,
    filetype = 'GTiff',
    datatype = dt,
    NAflag = varNA,
    gdal = c("COMPRESS=DEFLATE","PREDICTOR=2","ZLEVEL=9"),
    overwrite = TRUE,
    ...
  )
}

#' Save a raster stack to a netcdf file
#'
#' @param file A [`terra`] object to be saved.
#' @param fname A [`character`] stating the output destination.
#' @param varName Name for the NetCDF export variable.
#' @param varUnit Units for the NetCDF export variable.
#' @param varLong Long name for the NetCDF export variable.
#' @param dt The datatype to be written. Default is Float64
#' @param varNA The nodata value to be used. Default: \code{-9999}.
#' @param ... Other options.
#' @keywords utils, internal
#' @noRd
writeNetCDF <- function(file, fname,
                        varName, varUnit = NULL,
                        varLong = NULL, dt = "FLT4S", varNA = -9999, ...) {
  assertthat::assert_that(
    is.Raster(file),
    is.character(fname), is.character(dt),
    is.numeric(varNA)
  )
  check_package('ncdf4')
  if(!isNamespaceLoaded("ncdf4")) { attachNamespace("ncdf4");requireNamespace('ncdf4') }
  if(!assertthat::has_extension(fname,"nc")) fname <- paste0(fname,".nc")

  # Output NetCDF file
  terra::writeCDF(x = file,
                  filename = fname,
                  overwrite = TRUE,
                  varname = ifelse(is.null(varName),'Prediction',varName),
                  longname = ifelse(is.null(varLong),'',varLong),
                  zname = "Time",
                  unit = ifelse(is.null(varUnit),'',varUnit),
                  prec = "float", #TODO: Map against standard GDAL units!
                  compression = 9,
                  missval = varNA,
                  ...
  )

  # Add common attributes
  ncout <- ncdf4::nc_open(fname, write = TRUE)

  # add global attributes
  ncdf4::ncatt_put(ncout, 0,"title","Biodiversity suitability projection created with ibis.iSDM")

  history <- paste(Sys.info()['user'], date(), sep=", ")
  ncdf4::ncatt_put(ncout,0, "created", history)
  ncdf4::ncatt_put(ncout,0, "Conventions", "CF=1.5")

  # close the file, writing data to disk
  ncdf4::nc_close(ncout)

  invisible()
}

# ------------------------- #
#### Write summary methods ####

#' Generic function to write summary outputs from created models.
#'
#' @description The [`write_summary`] function is a wrapper function to create
#' summaries from fitted [`DistributionModel`] or [`BiodiversityScenario`]
#' objects. This function will extract parameters and statistics about the used
#' data from the input object and writes the output as either \code{'rds'} or
#' \code{'rdata'} file. Alternative, more open file formats are under
#' consideration.
#' @note No predictions or tabular data is saved through this function. Use
#' [`write_output()`] to save those.
#' @param mod Provided [`DistributionModel`] or [`BiodiversityScenario`] object.
#' @param fname A [`character`] depicting an output filename. The suffix
#'   determines the file type of the output (Options: \code{'rds'},
#'   \code{'rdata'}).
#' @param partial A [`logical`] value determining whether partial variable
#'   contributions should be calculated and added to the model summary. **Note
#'   that this can be rather slow** (Default: \code{FALSE}).
#' @param verbose [`logical`] indicating whether messages should be shown.
#'   Overwrites `getOption("ibis.setupmessages")` (Default: \code{TRUE}).
#' @param ... Any other arguments passed on the individual functions.
#' @returns No R-output is created. A file is written to the target direction.
#' @examples \dontrun{
#' x <- distribution(background) |>
#'  add_biodiversity_poipo(virtual_points, field_occurrence = 'observed', name = 'Virtual points')  |>
#'  add_predictors(pred_current, transform = 'scale',derivates = 'none') |>
#'  engine_xgboost(nrounds = 2000) |> train(varsel = FALSE, only_linear = TRUE)
#' write_summary(x, "testmodel.rds")
#' }
#' @keywords utils

#' @name write_summary
#' @aliases write_summary
#' @exportMethod write_summary
#' @export
NULL
methods::setGeneric("write_summary",
                    signature = methods::signature("mod","fname"),
                    function(mod, fname, partial = FALSE,
                             verbose = getOption("ibis.setupmessages"),...) standardGeneric("write_summary"))

#' @name write_summary
#' @rdname write_summary
#' @usage
#'   \S4method{write_summary}{ANY,character,logical,logical}(mod,fname,partial,verbose,...)
methods::setMethod(
  "write_summary",
  methods::signature(mod = "ANY", fname = "character"),
  function(mod, fname, partial = FALSE, verbose = getOption("ibis.setupmessages"), ...) {
    assertthat::assert_that(
      !missing(mod),
      is.character(fname),
      is.logical(partial),
      is.logical(verbose)
    )
    assertthat::assert_that(
      inherits(mod, "DistributionModel") || inherits(mod, "BiodiversityScenario"),
      msg = "Only objects created through `train()` or `project()` are supported!"
    )

    # Get file extension
    ext <- tolower( tools::file_ext(fname) )
    if(ext == "") ext <- "rds" # Assign rds as default
    ext <- match.arg(ext, choices = c("rds", "rdata"), several.ok = FALSE)
    fname <- paste0(tools::file_path_sans_ext(fname), ".", ext)
    if(file.exists(fname) && (verbose && getOption('ibis.setupmessages'))) myLog('[Output]','yellow','Overwriting existing file...')
    assertthat::assert_that(dir.exists(dirname(fname)))
    # --- #
    # Gather the statistics and parameters from the provided file
    output <- list()
    if(inherits(mod, "DistributionModel")){

      # Summarize the model object
      model <- mod$model

      # Model input summary in a tibble
      output[["input"]][["extent"]] <- as.matrix( terra::ext( model$background ) )
      output[["input"]][["predictors"]] <- model$predictors_types
      if(!is.Waiver(model$offset)) output[["input"]][["offset"]] <- names(model$offset) else output[["input"]][["offset"]] <- NA
      if(!is.Waiver(model$priors)){
        output[["input"]][["priors"]] <- model$priors$summary()
      } else output[["input"]][["priors"]] <- NA

      # Go over biodiversity datasets
      o <- data.frame()
      for(i in 1:length(model$biodiversity)){
        o <- rbind(o,
                     data.frame(id = names(model$biodiversity)[i],
                                name = model$biodiversity[[i]]$name,
                                type = model$biodiversity[[i]]$type,
                                family = model$biodiversity[[i]]$family,
                                equation = deparse1(model$biodiversity[[i]]$equation),
                                obs_pres = sum( as.numeric( as.character(model$biodiversity[[i]]$observations$observed) ) > 0 ),
                                obs_abs = sum( model$biodiversity[[i]]$observations$observed == 0 ),
                                n_predictors = length( model$biodiversity[[i]]$predictors_names )
                       )
                   )
      }
      output[["input"]][["biodiversity"]] <- o

      # Model parameters in a tibble
      output[["params"]][["id"]] <- as.character(model$id)
      output[["params"]][["runname"]] <- as.character(model$runname)
      output[["params"]][["algorithm"]] <- class(mod)[1]
      output[["params"]][["equation"]] <- mod$get_equation()
      # Collect settings and parameters if existing
      if( !is.Waiver(mod$get_data("params")) ){
        output[["params"]][["params"]] <- mod$get_data("params")
      }
      if( "settings" %in% names(mod) ){
        output[["params"]][["settings"]] <- mod$settings$data
      }

      # Model summary in a tibble and formula
      output[["output"]][["summary"]] <- mod$summary()
      pred <- mod$get_data("prediction")
      if(!is.null(pred) && !is.Waiver(pred)){
        output[["output"]][["resolution"]] <- terra::res( pred )
        output[["output"]][["prediction"]] <- names( pred )
      } else {
        output[["output"]][["resolution"]] <- NA
        output[["output"]][["prediction"]] <- NA
      }
      # Calculate partial estimates if set
      if(partial){
        if(verbose && getOption('ibis.setupmessages')) myLog('[Export]','green',paste0('Calculating partial variable contributions...'))
        message("Not yet added") # TODO:
        output[["output"]][["partial"]] <- NA
      } else {
        output[["output"]][["partial"]] <- NA
      }

    } else if(inherits(mod, "BiodiversityScenario")){
      # Summarize the model object
      model <- mod$get_model()

      # Model input summary in a tibble
      output[["input"]][["extent"]] <- as.matrix( terra::ext( model$model$background ) )
      output[["input"]][["predictors"]] <- mod$predictors$get_names()
      output[["input"]][["timerange"]] <- mod$get_timeperiod()
      output[["input"]][["predictor_time"]] <- mod$predictors$get_time()
      # Collect settings and parameters if existing
      if( !is.Waiver(mod$get_data("constraints")) ){
        output[["input"]][["constraints"]] <- mod$get_constraints()
      }

      # Model parameters in a tibble
      output[["params"]][["id"]] <- as.character(mod$modelid)
      output[["params"]][["runname"]] <- as.character(model$model$runname)
      output[["params"]][["algorithm"]] <- class(model)[1]
      if( "settings" %in% names(mod) ){
        output[["params"]][["settings"]] <- model$settings$data
      }

      # Model summary in a tibble and formula
      output[["output"]][["summary"]] <- mod$summary(plot = FALSE,...)
      if(!is.Waiver(mod$get_data() )){
        sc_dim <- stars::st_dimensions(mod$get_data())
        output[["output"]][["resolution"]] <- abs( c(x = sc_dim$x$delta, y = sc_dim$y$delta) )
        output[["output"]][["prediction"]] <- names(mod$get_data())
      } else {
        output[["output"]][["resolution"]] <- NA
        output[["output"]][["prediction"]] <- NA
      }
    }
    assertthat::assert_that(
      is.list(output),
      length(output)>0
    )
    # --- #
    # Write the output
    if(ext == "rds"){
      saveRDS(output, fname)
    } else if(ext == "rdata") {
      save(output, file = fname)
    } else {
      message("No compatible file format found. No summary output file ignored created!")
    }
    rm(output)
    invisible()
  }
)

# ------------------------- #
#### Save model for later use ####

#' Save a model for later use
#'
#' @description The `write_model` function (opposed to the `write_output`) is a
#' generic wrapper to writing a [`DistributionModel`] to disk. It is essentially
#' a wrapper to [`saveRDS`]. Models can be loaded again via the `load_model`
#' function.
#'
#' @note By default output files will be overwritten if already existing!
#'
#' @param mod Provided [`DistributionModel`] object.
#' @param fname A [`character`] depicting an output filename.
#' @param slim A [`logical`] option to whether unnecessary entries in the model
#'   object should be deleted. This deletes for example predictions or any other
#'   non-model content from the object (Default: \code{FALSE}).
#' @param verbose [`logical`] indicating whether messages should be shown.
#'   Overwrites `getOption("ibis.setupmessages")` (Default: \code{TRUE}).
#' @returns No R-output is created. A file is written to the target direction.
#' @examples \dontrun{
#' x <- distribution(background) |>
#'  add_biodiversity_poipo(virtual_points, field_occurrence = 'observed', name = 'Virtual points') |>
#'  add_predictors(pred_current, transform = 'scale',derivates = 'none') |>
#'  engine_xgboost(nrounds = 2000) |> train(varsel = FALSE, only_linear = TRUE)
#' write_model(x, "testmodel.rds")
#' }

#' @name write_model
#' @aliases write_model
#' @seealso load_model
#' @keywords utils
#' @exportMethod write_model
#' @export
NULL
methods::setGeneric("write_model",
                    signature = methods::signature("mod"),
                    function(mod, fname, slim = FALSE, verbose = getOption("ibis.setupmessages")) standardGeneric("write_model"))

#' @name write_model
#' @rdname write_model
#' @usage
#'   \S4method{write_model}{ANY,character,logical,logical}(mod,fname,slim,verbose)
methods::setMethod(
  "write_model",
  methods::signature(mod = "ANY"),
  function(mod, fname, slim = FALSE, verbose = getOption("ibis.setupmessages")) {
    assertthat::assert_that(
      !missing(mod),
      is.character(fname),
      is.logical(slim),
      is.logical(verbose)
    )
    # Check that provided model is correct
    assertthat::assert_that(inherits(mod, "DistributionModel"),
                            !is.Waiver(mod$get_data("fit_best")) )
    # And model format
    assertthat::assert_that( assertthat::has_extension(fname, "rds"))

    # Don't save the predictors object as it has distinct memory points
    if(inherits(mod$model$predictors_object, "PredictorDataset")){
      ats <- attributes( mod$model$predictors_object$get_data() )
      mod$model$predictors_object <- ats
    }

    # If slim, remove some ballast
    if(slim){
      if(!is.Waiver(mod$get_data("prediction"))) mod$fits$prediction <- NULL
    } else {
      # Save the prediction as data.frame if set
      if(!is.Waiver(mod$get_data("prediction"))){
        mod$fits$prediction <- terra::as.data.frame(mod$get_data(), xy = TRUE, na.rm = NA)
      }
    }

    # Save output
    if(verbose && getOption('ibis.setupmessages')) myLog('[Export]','green',paste0('Writing model to file...'))
    saveRDS(mod, fname)
    invisible()
  }
)

#' Load a pre-computed model
#'
#' @description The `load_model` function (opposed to the `write_model`) loads
#' previous saved [`DistributionModel`]. It is essentially a wrapper to
#' [`readRDS`].
#'
#' When models are loaded, they are briefly checked for their validity and
#' presence of necessary components.
#'
#' @param fname A [`character`] depicting an output filename.
#' @param verbose [`logical`] indicating whether messages should be shown.
#'   Overwrites `getOption("ibis.setupmessages")` (Default: \code{TRUE}).
#' @returns A [`DistributionModel`] object.
#' @examples \dontrun{
#' # Load model
#' mod <- load_model("testmodel.rds")
#'
#' summary(mod)
#' }

#' @name load_model
#' @aliases load_model
#' @seealso write_model
#' @keywords utils
#' @exportMethod load_model
#' @export
NULL
methods::setGeneric("load_model",
                    signature = methods::signature("fname"),
                    function(fname, verbose = getOption("ibis.setupmessages")) standardGeneric("load_model"))

#' @name load_model
#' @rdname load_model
#' @usage \S4method{load_model}{character,logical}(fname,verbose)
methods::setMethod(
  "load_model",
  methods::signature(fname = "character"),
  function(fname, verbose = getOption("ibis.setupmessages")) {
    assertthat::assert_that(
      is.character(fname),
      is.logical(verbose)
    )
    # Check that file exists and is an rds file
    assertthat::assert_that(
      assertthat::has_extension(fname, "rds"),
      file.exists(fname)
    )

    # Get file size
    fz <- file.size(fname) |> structure(class="object_size") |>
      format(units = "auto")

    if(verbose && getOption('ibis.setupmessages')) myLog('[Export]','green',paste0('Loading previously serialized model (size: ',fz,')'))
    # Load file
    mod <- readRDS(fname)

    # Convert predictions back to terra if data.frame
    model <- mod$model
    if(is.list( model$predictors_object ) ){
      ras <- terra::rast(model$predictors, type = "xyz",
                         crs = terra::crs(model$background))
      assertthat::assert_that(all(names(ras) %in% model$predictors_names))
      # Get any previously set attributes
      ats <- model$predictors_object
      attr(ras, "int_variables") <- ats[['int_variables']]
      attr(ras, 'has_factors') <- ats[['has_factors']]
      attr(ras,'transform') <- ats[['transform']]

      # Make a new predictors object
      o <- bdproto(NULL, PredictorDataset,
              id = new_id(),
              data = ras
      )
      assertthat::assert_that(all( o$get_names() %in% model$predictors_names ))
      if(is.Raster(ras)) mod$model$predictors_object <- o
      rm(o)
    }

    # Reload prediction if data.frame found
    if(is.data.frame(mod$fits$prediction)){
      if(nrow(mod$fits$prediction)>0){
        ras <- terra::rast(mod$fits$prediction,
                           type = "xyz",
                           crs = terra::crs(model$background))
        mod$fits$prediction <- ras
        rm(ras)
      } else {
        mod$fits$prediction <- NULL
      }
    }

    # --- #
    # Make some checks #
    assertthat::assert_that(
      inherits(mod, "DistributionModel"),
      utils::hasName(mod, "model"),
      !is.Waiver(mod$get_data("fit_best"))
    )
    # Check that model type is known
    assertthat::assert_that( any(sapply(class(mod), function(z) z %in% getOption("ibis.engines"))) )
    # Depending on engine, check package and load them

    if(inherits(mod, "GDB-Model")){
      check_package("mboost")
    } else if(inherits(mod, "BART-Model")){
      check_package("dbarts")
    } else if(inherits(mod, "INLABRU-Model")){
      check_package("INLA")
      check_package("inlabru")
    } else if(inherits(mod, "BREG-Model")){
      check_package("BoomSpikeSlab")
    } else if(inherits(mod, "GLMNET-Model")){
      check_package("glmnet")
      check_package("glmnetUtils")
    } else if(inherits(mod, "STAN-Model")){
      check_package("rstan")
      check_package("cmdstanr")
    } else if(inherits(mod, "XGBOOST-Model")){
      check_package("xgboost")
    }

    # --- #
    # Return the model
    return(mod)
  }
)
