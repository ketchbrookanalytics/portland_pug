
# 1.0 SETUP ----

## 1.1 Load Packages ----

library(readr)   # read data from .csv
library(dplyr)   # general data prep
library(lubridate)   # work with dates
library(tsibble)   # work with time series data
library(forecast)   # neural net algorithm
library(ModelMetrics)   # compute model fit statistics


## 1.2 Import Data ----

##                       ##
##    SHOW DATA IN CSV   ##
##                       ##

# Import historical prison population data
prison_data <- readr::read_csv(
  file = "C:/Users/18602/Documents/Github_Repos_Master/portland_pug/data/prison_data.csv", 
  col_types = readr::cols(
    date = readr::col_date(format = "%m/%d/%Y"), 
    population = readr::col_number()
  )
)

##                    ##
##    LOOK AT TABLE   ##
##                    ##


## 1.3 Split Train/Test ----

train <- prison_data %>% 
  dplyr::filter(date < as.Date("2019-01-01")) %>% 
  tsibble::as_tsibble(index = date)

test <- prison_data %>% 
  dplyr::filter(date >= as.Date("2019-01-01")) %>% 
  tsibble::as_tsibble(index = date)

backtest <- prison_data %>% 
  dplyr::bind_rows(
    data.frame(
      date = seq.Date(
        from = as.Date("2019-11-01"), 
        to = as.Date("2020-10-01"), 
        by = "month"
      ), 
      population = NA
    )
  ) %>% 
  tsibble::as_tsibble(index = date)

##                    ##
##   LOOK AT TABLES   ##
##                    ##


# 2.0 Fit Models ----

## 2.1 ARIMA ----
arima_fit <- arima(
  x = train$population, 
  order = c(1, 1, 12)
)

# Compare 
set.seed(43)
comparison <- test %>% 
  dplyr::mutate(arima_preds = as.integer(
    simulate(
      arima_fit, 
      nsim = nrow(test)
    )
  ))

##                    ##
##  CHECK COMPARISON  ##
##                    ##


## 2.2 Simple RNN ----

rnn_fit <- forecast::nnetar(train$population)

set.seed(43)
comparison <- comparison %>% 
  dplyr::mutate(rnn_preds = as.integer(
    simulate(
      rnn_fit, 
      nsim = nrow(test)
    )
  ))


##                    ##
##  CHECK COMPARISON  ##
##                    ##


# 3.0 Compare Model Accuracy ----

metrics <- data.frame(
  
  Model = c(rep(c("ARIMA", "Neural.Net"), 2)), 
  
  Metric = c(rep("RMSE", 2), rep("MAE", 2)), 
  
  Error = c(ModelMetrics::rmse(comparison$population, comparison$arima_preds), 
            ModelMetrics::rmse(comparison$population, comparison$rnn_preds), 
            ModelMetrics::mae(comparison$population, comparison$arima_preds), 
            ModelMetrics::mae(comparison$population, comparison$rnn_preds))
  
)

# 4.0 

# Re-fit RNN model using all historical data
train_new <- dplyr::bind_rows(train, test)

rnn_fit_new <- forecast::nnetar(train_new$population)

set.seed(43)
backtest <- backtest %>% 
  dplyr::mutate(rnn_preds = c(
    rep(NA, nrow(prison_data)), 
    as.integer(
      simulate(
        rnn_fit_new, 
        nsim = 12
      )
    )
  ))
