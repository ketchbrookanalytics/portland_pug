
# 1.0 SETUP ----

## 1.1 Load Packages ----

library(readr)   # read data from .csv
library(dplyr)   # general data prep
library(lubridate)   # work with dates
library(tsibble)   # work with time series data
library(forecast)   # neural net algorithm
library(ModelMetrics)   # compute model fit statistics


# 1.2 Import Data ----

# Import historical prison population data
prison_data <- readr::read_csv(
  file = "data/prison_data.csv", 
  show_col_types = FALSE
)

##                    ##
##    LOOK AT TABLE   ##
##                    ##

# Split data into train & test sets

train <- prison.data %>% 
  tsibble::as_tsibble(index = date) %>% 
  dplyr::filter(date < "2019-01-01")

test <- prison.data %>% 
  tsibble::as_tsibble(index = date) %>% 
  dplyr::filter(date >= "2019-01-01")

backtest.data <- prison.data %>% 
  dplyr::bind_rows(
    data.frame(
      date = seq.Date(
        from = as.Date("2020-04-01"), 
        to = as.Date("2020-12-01"), 
        by = "month"
      ), 
      population = NA
    )
  ) %>% 
  tsibble::as_tsibble(index = date) %>% 
  dplyr::filter(date >= "2020-01-01")


##                    ##
##   LOOK AT TABLES   ##
##                    ##


#################
###   ARIMA   ###
#################

arima.modl <- arima(
  x = train.data$population, 
  order = c(1,1,12)
)

set.seed(43)
comparison <- test.data %>% 
  dplyr::mutate(arima.preds = as.integer(
    simulate(
      arima.modl, 
      nsim = 12
    )
  ))

##                    ##
##  CHECK COMPARISON  ##
##                    ##


#####################################
###           RNN Model           ###
#####################################

nnet.modl <- forecast::nnetar(train.data$population)

set.seed(1234)
comparison <- comparison %>% 
  dplyr::mutate(nnet.preds = as.integer(
    simulate(
      nnet.modl, 
      nsim = 12
    )
  ))


##                    ##
##  CHECK COMPARISON  ##
##                    ##


# Create some comparative statistics

metrics <- data.frame(Model = c(rep(c("ARIMA", "Neural.Net"), 2)), 
                         Metric = c(rep("RMSE", 2), rep("MAE", 2)), 
                         Error = c(ModelMetrics::rmse(comparison$population, 
                                                      comparison$arima.preds), 
                                   ModelMetrics::rmse(comparison$population, 
                                                      comparison$nnet.preds), 
                                   ModelMetrics::mae(comparison$population, 
                                                     comparison$arima.preds), 
                                   ModelMetrics::mae(comparison$population, 
                                                     comparison$nnet.preds)))


#######################################


# Now use the Neural Network model to make predictions for 2019

train.data.2020 <- prison.data %>% 
  tsibble::as_tsibble(index = date) %>% 
  dplyr::filter(date < as.Date("2020-01-01"))

nnet.modl.2020 <- forecast::nnetar(train.data.2020$population)

set.seed(1234)
backtest.data <- backtest.data %>% 
  dplyr::mutate(nnet.preds = as.integer(
    simulate(
      nnet.modl.2020, 
      nsim = 12
    )
  ))
