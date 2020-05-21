
<!-- README.md is generated from README.Rmd. Please edit that file -->

# octaver

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of octaver is to provide an interface to Octave. octave

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("kvasilopoulos/octaver")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(octaver)
## basic example code
pr <- OctaveSession$new()
pr$eval("2+2")
#> ans =  4

pr$state()
#> [1] "running"
pr$kill()
#> [1] TRUE
pr$state()
#> [1] "terminated"
```
