shinyUI(fluidPage(
    titlePanel("Sales Forecast Sample"),
    wellPanel("Demonstrate the different sales forecasts using 
              historical data from fiscal year 2013 to the first half of fiscal 
              year 2015.  The types of forecast models are described by Hyndman 
              and Athanasopoulos in their new book ",
              a("Forecasting: principles and practice", href="https://www.otexts.org/fpp"),
              p("The targets are the goals that the sales organization has set for themselves.
                Use the slider to predict how far out to forecast.")),
    sidebarLayout(
        sidebarPanel(helpText("Choose forecasting models for US Sales"),
                     selectInput("var", label="Choose forecast model", 
                                 choices=list("Exponential Smoothing", "Regression", "Mean", "Naive", "Seasonal Naive", "Arima", "Neural Network"),
                                 selected="Exponential Smoothing"),
                     checkboxInput("showTargets", "Show Targets", value = TRUE), 
                     sliderInput("range", label="Number of months to forecast", min=1, max=24, value=c(6))
        ),
        mainPanel(plotOutput("forecast"))
    )
))