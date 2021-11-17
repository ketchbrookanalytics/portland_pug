

library(plotly)

plotly::plot_ly(
  x = ~prison_data$date, 
  y = ~prison_data$population, 
  type = "scatter", 
  mode = "lines"
) %>% 
  plotly::layout(
    title = "Prison Population by Date", 
    xaxis = list(title = ""), 
    yaxis = list(title = "Population")
  )
