
<!-- README.md is generated from README.Rmd. Please edit that file -->

# octaver

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R-CMD-check](https://github.com/kvasilopoulos/octaver/workflows/R-CMD-check/badge.svg)](https://github.com/kvasilopoulos/octaver/actions)
<!-- badges: end -->

The goal of octaver is to provide an interface to Octave

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
find_octave()
#>                                           octave-cli 
#> "C:\\Octave\\OCTAVE~1.0\\mingw64\\bin\\OCC5B3~1.EXE"
```

``` octave
A = 1;
A
```
