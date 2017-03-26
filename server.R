library(shiny)
library(caret)
library(ISLR)

shinyServer(function(input, output) {
  # prepare data for training and testing model
  reactive({set.seed(input$seed)})
  Wage <- subset(Wage, select = -c(logwage))
  inTrain <- reactive({createDataPartition(y = Wage$wage, p = input$train/100, list = FALSE)})
  training <- reactive({Wage[inTrain(),]})
  testing <- reactive({Wage[-inTrain(),]})
  
  # build training parameters
  formula <- reactive({
    if (is.null(input$variable)) {
      as.formula("wage~.")
    } else {
      variable <- input$variable[[1]]
      if (length(input$variable) > 1) {
        for (i in 2:length(input$variable)) {
          variable <- paste(variable, input$variable[[i]], sep = "+")
        }
      }
      as.formula(paste0("wage~", variable))
    }
  })
  
  # fit different models with caret
  mod <- reactive({
    if (input$method == "rf_cv") {
      train(formula(), data = training(), method="rf", trControl = trainControl(method = "cv", number = 3))
    } else if (input$method == "rf_boot") {
      train(formula(), data = training(), method="rf", trControl = trainControl(method = "boot", number = 3))
    } else if (input$method == "gbm") {
      train(formula(), data = training(), method=input$method, verbose = FALSE)
    } else {
      train(formula(), data = training(), method=input$method)
    }
  })
  
  # predicting test dataset
  pred <- reactive({predict(mod(), testing())})
  
  # plot model
  output$Mod <- renderPlot({
    if (input$method != "glm") {
      plot(mod())
    }
  })
  
  # plot final model
  output$finMod <- renderPlot({
    if (input$method == "glm") {
      par(mfrow = c(2, 2))
    }
    plot(mod()$finalModel)
  })

  # plot prediction result
  output$pred <- renderPlot({
    plot(testing()$wage, pred(), xlab = "Real Wage", ylab = "Predicted Wage", main = "Test Set Prediction")
    lines(0:300, 0:300, col = "grey") # line indicating perfect match
  })
  
  # output RMSE
  output$train_rmse <- renderText({min(mod()$results$RMSE)})
  output$test_rmse <- renderText({sqrt(sum((pred() - testing()$wage)^2))})
  
  # output final model summary
  output$finalSummary <- renderPrint({
    print(mod()$finalModel)
  })
  
  # output model summary
  output$summary <- renderPrint({
    print(mod())
    summary(mod())
  })
  
})
