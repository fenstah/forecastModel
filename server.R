library(fpp)

shinyServer(function(input, output) {
    #app plat targets for the year
    targets<-c(8881435,15740782,25105396,11531005,13416427,18873008,10479056,10124275,20615725,11746634,14883688,27144702)
    ts.targets<-ts(targets, start=c(2015,1), freq=12)
    
    #read in pre-audit YOY data
    yoy.total.nws<-read.csv("data/YOY_NWS.csv")
    yoy.total.nws<-yoy.total.nws[1:6]
    yoy.total.byMonth<-with(yoy.total.nws, aggregate(Sum.of.NWS.MS.Amt.CUS, by=list(NWS.Creditted....MS.Fiscal.Month.Alt.Name), sum))
    yoy.total.byMonth<-yoy.total.byMonth[-length(yoy.total.byMonth$Group.1),]    #remove the last month since it is incomplete
    colnames(yoy.total.byMonth)<-c("Fiscal.Month", "NWS.Total.PreAudit")
    
    #determine social impact 
    yoy.sharepoint<-subset(yoy.total.nws, grepl("^SharePoint",Primary.Product, perl=TRUE), 1:6)
    yoy.social<-subset(yoy.sharepoint, Business.Scenario %in% c("Enterprise Social", "Productivity Applications", "Adoption & Change Management", "Enterprise Strategy ESP", "Enterprise Social Planning_ESP"))
    yoy.social.byMonth<-with(yoy.social, aggregate(Sum.of.NWS.MS.Amt.CUS, by=list(NWS.Creditted....MS.Fiscal.Month.Alt.Name), sum))
    colnames(yoy.social.byMonth)<-c("Fiscal.Month", "NWS.Total.Social")
    
    #current numbers (i.e., post-audit)
    current.NWS<-read.csv("data/currentyear.csv")
    current.NWS$Total<-as.numeric(gsub("[(]","-",(gsub("[)|,|$]","",as.character(current.NWS$Total)))))
    current.byMonth<-with(current.NWS, aggregate(Total, by = list(MS.Fiscal.Month), sum))
    colnames(current.byMonth)<-c("Fiscal.Month", "NWS.Total.PostAudit")
    
    #break down by regions
    regionalBreakdown <- function (regionName) {
        #YOY data for region
        regionalDF.preAudit<-with((subset(yoy.total.nws, Current.Delivery...Sales.SubLocation.Name == regionName, 1:6)), aggregate(Sum.of.NWS.MS.Amt.CUS, by=list(NWS.Creditted....MS.Fiscal.Month.Alt.Name), sum))
        colnames(regionalDF.preAudit)<-c("Fiscal.Month", "NWS.PreAudit")
        
        #Current year for region
        regionalDF.postAudit<-with(subset(current.NWS, Sales.Sublocation.Name == regionName), aggregate(Total, by=list(MS.Fiscal.Month), sum))    
        colnames(regionalDF.postAudit)<-c("Fiscal.Month", "NWS.PostAudit")    
        
        regionalDF.preAudit<-merge(regionalDF.preAudit, regionalDF.postAudit, by="Fiscal.Month", all=TRUE)
        regionalDF.preAudit[is.na(regionalDF.preAudit$NWS.PostAudit),3]<-regionalDF.preAudit[is.na(regionalDF.preAudit$NWS.PostAudit),2]    
        colnames(regionalDF.preAudit)[3]<-regionName
        return (regionalDF.preAudit[-2])
    }
    yoy.east <- regionalBreakdown("East")
    yoy.central <- regionalBreakdown("Central")
    yoy.west <- regionalBreakdown("West")
    yoy.civilian <- regionalBreakdown("Civilian")
    yoy.nsg <- regionalBreakdown("NSG")
    yoy.dod <- regionalBreakdown("DOD")
    
    #need to combine SLG and EDU for SLGE
    yoy.slge <- merge(regionalBreakdown("SLG"), regionalBreakdown("Edu"), by="Fiscal.Month", all=TRUE)
    yoy.slge[is.na(yoy.slge)] <- 0
    yoy.slge$SLGE<-yoy.slge$SLG + yoy.slge$Edu
    yoy.slge<-yoy.slge[c(1,4)]
    
    #put it all together in one data frame
    appPlatNWS.DF<-merge(yoy.total.byMonth, yoy.social.byMonth, by="Fiscal.Month", all.x=TRUE)
    appPlatNWS.DF[is.na(appPlatNWS.DF)] <- 0
    appPlatNWS.DF$NWS.Total.Social<-appPlatNWS.DF$NWS.Total.PreAudit-appPlatNWS.DF$NWS.Total.Social
    appPlatNWS.DF<-merge(appPlatNWS.DF, current.byMonth, by="Fiscal.Month", all.x=TRUE)
    appPlatNWS.DF[is.na(appPlatNWS.DF$NWS.Total.PostAudit),4]<-appPlatNWS.DF[is.na(appPlatNWS.DF$NWS.Total.PostAudit),3]
    appPlatNWS.DF<-merge(appPlatNWS.DF, yoy.east, by="Fiscal.Month", all.x=TRUE)
    appPlatNWS.DF<-merge(appPlatNWS.DF, yoy.central, by="Fiscal.Month", all.x=TRUE)
    appPlatNWS.DF<-merge(appPlatNWS.DF, yoy.west, by="Fiscal.Month", all.x=TRUE)
    appPlatNWS.DF<-merge(appPlatNWS.DF, yoy.civilian, by="Fiscal.Month", all.x=TRUE)
    appPlatNWS.DF<-merge(appPlatNWS.DF, yoy.nsg, by="Fiscal.Month", all.x=TRUE)
    appPlatNWS.DF[is.na(appPlatNWS.DF)] <- 0  #NSG had no sales in FY14 P4
    appPlatNWS.DF<-merge(appPlatNWS.DF, yoy.dod, by="Fiscal.Month", all.x=TRUE)
    appPlatNWS.DF<-merge(appPlatNWS.DF, yoy.slge, by="Fiscal.Month", all.x=TRUE)
    
    
    options(scipen=5)
    
    plotForecast <- function (filter, forecastMethod, filterLabel, targets=NULL, forecastperiods=6) {
        timeSeries<-ts(filter[,2],start=c(2013,1), freq=12)
        fit<-switch(forecastMethod, 
                    "regression" = tslm(timeSeries ~ trend + season -1),
                    "ets" = ets(timeSeries, model="AAN"),
                    "mean" = meanf(timeSeries, h=forecastperiods),
                    "naive" = naive(timeSeries, h=forecastperiods),
                    "snaive" = snaive(timeSeries, h=forecastperiods),
                    "arima" = auto.arima(timeSeries),
                    "nnet" = nnetar(timeSeries))
        fcst<-forecast(fit, h=forecastperiods)
        projectedNWS<-sum(subset(filter, grepl("^FY2015", Fiscal.Month))[2],fcst$mean)
        #subTitle<-paste("forecast=",sprintf("$%3.2f", projectedNWS))
        subTitle<-paste("forecast=",format(projectedNWS,big.mark=",",scientific=F))
        plot(fcst, main=paste("Sales Forecast (",filterLabel,")"), sub=subTitle)
        lines(fitted(fit), col=2)
        if(!is.null(targets)) {
            lines(ts.targets, col=3, lwd = 4)
            legend("topleft", lty=1, col=c(1,2,3), legend=c("Actual", "Predicted", "Targets"))
        }
        else legend("topleft", lty=1, col=c(1,2), legend=c("Actual", "Predicted"))

    }
    
    current<-merge(appPlatNWS.DF[0:1], current.byMonth, by="Fiscal.Month", all=TRUE)
    current[is.na(current)]<-appPlatNWS.DF[is.na(current$NWS.Total.PostAudit),3]
    current<-current[-length(current$Fiscal.Month),]      
    
    output$forecast<- renderPlot({
        args<-list(current)
        args$forecastMethod <- switch(input$var, 
                                      "Exponential Smoothing" = "ets",
                                      "Regression" = "regression",
                                      "Mean" = "mean",
                                      "Naive" = "naive",
                                      "Seasonal Naive" = "snaive", 
                                      "Arima" = "arima", 
                                      "Neural Network" = "nnet")        
        args$filterLabel<-input$var
        if(input$showTargets) args$targets<-ts.targets
        args$forecastperiods<-input$range[1]
        do.call(plotForecast, args)
    })   
})
