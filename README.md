
<!-- README.md is generated from README.Rmd. Please this file -->

# ibis package

<!-- <a href='https://github.com/iiasa/rN2000'><img src="man/figures/logo.png" align="right"height=140/></a> --->

The ibis package - An **I**ntegrated model for **B**iod**I**versity
distribution projection**S**

## Installation

Currently only as development version on GitHub

``` r
install.packages("devtools")
devtools::install_github("IIASA/ibis")
```

## Usage

**In development !!!**

### Load package

``` r
library(ibis)
library(raster)
library(sf)

background <- raster::raster(system.file('extdata/europegrid_50km.tif', package='ibis'))
# Get test species
virtual_points <- sf::st_read(system.file('extdata/input_data.gpkg', package='ibis'),'points',quiet = TRUE)
virtual_range <- sf::st_read(system.file('extdata/input_data.gpkg', package='ibis'),'range',quiet = TRUE)
# Get list of test predictors
ll <- list.files(system.file('extdata/predictors/',package = 'ibis'),full.names = T)
predictors <- raster::stack(ll);names(predictors) <- tools::file_path_sans_ext(basename(ll))

x <- distribution(background) %>%
  add_biodiversity_poipo(virtual_points,field_occurrence = 'Observed',name = 'Virtual points') %>%
  add_predictors(predictors,prep = 'scale') %>% 
  engine_inla()
#> Warning in proj4string(sp): CRS object has comment, which is lost in output

# Train a Model
mod <- train(x, runname = 'test')

# Get model object from prediction
prediction <- mod$get_data('prediction')

plot(prediction$mean, main = 'Posterior prediction (mean lambda) using INLA')
plot(as(virtual_points,'Spatial'),add =TRUE)
```

![](man/figures/README-unnamed-chunk-2-1.png)<!-- -->

``` r
# In the model
#x$biodiversity
#x$predictors
#

# Second model with range and spatial effect
# x2 <- x %>% 
#   add_biodiversity_polpo(virtual_range,field_occurrence = 'Observed',name = 'Virtual range') %>%
#   add_latent_spatial()
```
