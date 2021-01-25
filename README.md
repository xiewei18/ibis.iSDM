
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

**In development \!\!\!**

### Load package

``` r
library(ibis)
background <- raster::raster(system.file('extdata/europegrid_50km.tif', package='ibis'))
# Get test species
virtual_points <- sf::st_read(system.file('extdata/input_data.gpkg', package='ibis'),'points',quiet = TRUE)
virtual_range <- sf::st_read(system.file('extdata/input_data.gpkg', package='ibis'),'range',quiet = TRUE)
# Get list of test predictors
ll <- list.files(system.file('extdata/predictors/',package = 'ibis'),full.names = T)
predictors <- raster::stack(ll);names(predictors) <- tools::file_path_sans_ext(basename(ll))

d1 <- distribution(background) %>%
  add_biodiversity_poipo(virtual_points,field_occurrence = 'Observed',name = 'Virtual points') %>%
  add_biodiversity_polpo(virtual_range,field_occurrence = 'Observed',name = 'Virtual range') %>%
  add_predictors(predictors)
d1

# More to be follow... TBD
```