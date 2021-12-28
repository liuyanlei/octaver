
<!-- README.md is generated from README.Rmd. Please edit that file -->

# octaver

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/octaver)](https://CRAN.R-project.org/package=octaver)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R-CMD-check](https://github.com/kvasilopoulos/octaver/workflows/R-CMD-check/badge.svg)](https://github.com/kvasilopoulos/octaver/actions)
[![Codecov test
coverage](https://codecov.io/gh/kvasilopoulos/octaver/branch/master/graph/badge.svg)](https://codecov.io/gh/kvasilopoulos/octaver?branch=master)
<!-- badges: end -->

The goal of octaver is to provide an interface to Octave

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("liuyanlei/octaver")
```

## Session

``` r
library(octaver)
find_octave()
#>                                           octave-cli 
#> "C:\\Octave\\OCTAVE~1.0\\mingw64\\bin\\OCC5B3~1.EXE"

## basic example code
pr <- OctaveSession$new()
pr$eval("2+2")
#> ans  =  4

pr$eval("A = 2+2")
#> A  =  4
pr$eval("A")
#> A  =  4

pr$kill()
#> Octave Session, finished, pid 10996.
```

## REPL

## Knitr engine

``` octave
A = 1;
A
#> A
#>  =  1
```

## API

### Various .m scripts

m\_

### Run

oct\_run(): oct\_addpath():

### Session & Repl

<!-- > Steam connections -->

oct\_session(): oct\_repl():

### Knitr

set\_oct\_engine():

### Read & Write

write\_mat(): read\_mat():

### Installation helpers

install\_oct(): install\_pkg():

### Other helpers

has\_octave(): octave\_path(): find\_octave(): list\_pkgs():
