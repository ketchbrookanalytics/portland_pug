![](www/ka_logo.jpg)

<hr>

# Data Visualization through the Predictive Modeling Lifecycle with Power BI & R

This repository contains materials associated with the presentation given by [Michael Thomas](https://www.linkedin.com/in/michaeljthomas2/) to the [Portland Power BI Users Group](https://www.meetup.com/Portland-Power-BI-User-Group/events/278259627/) on 2021-11-17.

## Installation

1. Clone this repository to your local machine

2. Open the **noisy.Rproj** file from the directory on your local machine where you cloned this repository. This should install the {renv} package if you do not already have it installed, but if you don’t see that happen in the console, run `install.packages("renv")`.

3. Run `renv::restore()` to install the package dependencies needed to run this app successfully

## Purpose

The presentation uses data from [data.ct.gov](https://data.ct.gov) on prison population counts in the State of Connecticut to build *time-series forecasting* models to forecast the future monthly prison population in the State.

## Structure (What's in Here?)

1. The [data/](data) folder contains the raw *.csv* data with the total prison population counts by month

2. The [forecast.R](forecast.R) script builds the ARIMA & RNN (*recurrent neural network*) models, and simulates the next 12 months of values for the forecasted population 

3. The [interactive_viz_example.R](interactive_viz_example.R) script creates a **{plotly}** visualization (which is HTML under the hood)

4. The [CT Prison Population Forecast.pbix](CT%20Prison%20Population%20Forecast.pbix) file contains the Power BI report used in the presentation

*** 

# Questions?

Contact us at [info@ketchbrookanalytics.com](mailto:info@ketchbrookanalytics.com) to learn more about how we can help you achieve your data science goals!
