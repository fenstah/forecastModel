---
title       : The Power of Forecasting Sales 
subtitle    : Forecasting using Hyndman and Athanasopoulos Methods
author      : Lenny Fenster
job         : CTO
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : [bootstrap, shiny, interactive, mathjax]            # {mathjax, quiz, bootstrap}
mode        : standalone    # {standalone, draft}
github:
    user: fenstah
    repo: forecastModel    
--- 

<style>
.title-slide {background-color: #FFF}
</style>

## Why Forecast

1. Bad forecasts may be dangerous and business killers
2. Understanding forecast trends and seasonality can help make better decisions
3. Forecasts assume the environment is changing but make no assumptions as to 
_HOW_ it is changing. 

<br/><br/>
Why doesn't everyone forecast?
>- Good forecasting is difficult.

--- 

## Types of Forecasting Methods

1. __Average (Mean)__:  forecasts of all future values are equal to the mean of the historical data.
2. __Naive__: 
    forecasts are simply set to be the value of the last observation
3. __Seasonal Naive__: 
    forecast are set to the last observed value from the same season of the year (e.g., the same month of the previous year).
4. __Regression__:
    forecast and predictor variables are assumed to be related by the simple linear model
5. __Exponential Smoothing__:
    Between Average and Naive; attaches larger weights to more recent observations than to observations from the distant past. Forecasts are calculated using weighted averages where the weights decrease exponentially as observations come from further in the past
6. __Arima__:
    While exponential smoothing models were based on a description of trend and seasonality in the data, ARIMA models aim to describe the autocorrelations in the data
7. __Neural Network__:
    Based on simple mathematical models of the brain. They allow complex nonlinear relationships between the response variable and its predictors


---

## Targets and Forecast Length

- __Targets__: Quota set for the sales organization prior to the start of the fiscal year.  
Ideally set on observed seasonality but often not done with a robust forecasting method.  
Showing targets against forecast can help identify the kind of gap we might expect versus the 
initial targets

- __Forecast Length__:  As the forecast length (in units of months for this example) increase, 
the prediciton confidence will generally decrease.  It can be valuable to vary the amount of time
for which one wants to forecast. For example, we will default to six months to forecast until the end 
of the fiscal year but may want to decrease that number to forecast how we might end the current 
quarter.

---


## Putting it all together
<div class="row-fluid">
  <div class="span4">
    <form class="well">
      <span class="help-block">Forecasting model Selection:</span>
      <label class="control-label" for="var">Choose forecast model</label>
      <select id="var"><option value="Exponential Smoothing" selected>Exponential Smoothing</option>
<option value="Regression">Regression</option>
<option value="Mean">Mean</option>
<option value="Naive">Naive</option>
<option value="Seasonal Naive">Seasonal Naive</option>
<option value="Arima">Arima</option>
<option value="Neural Network">Neural Network</option></select>
      <script type="application/json" data-for="var" data-nonempty="">{}</script>
      <label class="checkbox" for="showTargets">
        <input id="showTargets" type="checkbox" checked="checked"/>
        <span>Show Targets</span>
      </label>
      <div>
        <label class="control-label" for="range">Number of months to forecast</label>
        <input id="range" type="slider" name="range" value="6" class="jslider" data-from="1" data-to="24" data-step="1" data-skin="plastic" data-round="FALSE" data-locale="us" data-format="#,##0.#####" data-scale="|;|;|;|;|;|;|;|;|;|;|;|;|;|;|;|;|;|;|;|;|;|;|;|" data-smooth="FALSE"/>
      </div>
    </form>
  </div>
  <div class="span8">
    <div id="forecast" class="shiny-plot-output" style="width: 100% ; height: 400px"></div>
  </div>
</div>

--- 

## Determining Forecast Accuracy
Forecast error is $e_{i}=y_{i}-\hat{y}_{i}$ where $y_{i}$ denotes  the _i_ th observation and $\hat{y}_{i}$ denotes a forecast of $y_{i}$. Types of measuring forecast accuracy are:
$$
\begin{aligned} 
\text{Mean absolute error: MAE} = \text{mean}(|e_{i}|),\\
\text{Root mean squared error: RMSE} = \sqrt{\text{mean}(e_{i}^2)},\\
\text{Mean absolute percentage error: MAPE} = \text{mean}(|p_{i}|),\\
\text{MASE} = \text{mean}(|q_{j}|).
\end{aligned}
$$
Mean Absolute Squared Error, proposed by Hyndman and Koehler (2006), is an alternative to percentage errors when comparing forecast accuracy across series on different scales. For a seasonal naive forecast (e.g.), the scaled error can be defined using:
$$
\begin{aligned}
q_{j} = \frac{\displaystyle e_{j}}{\displaystyle\frac{1}{T-m}\sum_{t=m+1}^T
|y_{t}-y_{t-m}|} \end{aligned}
$$

The forecast accuracy measures for the forecast selected in the previous slide are:
<div class="row-fluid">
  <div class="span8">
    <div id="acc" class="shiny-html-output"></div>
  </div>
</div>


