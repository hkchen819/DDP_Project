library(shiny)

# Define UI for application that demo caret capabilities
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Caret Demo: Predicting Wage"),
  
  # Sidebar with training model customization 
  sidebarLayout(
    sidebarPanel(
      numericInput("seed",
                   label = "Set random seed:",
                   value = 12321),
      sliderInput("train",
                  "Set data partition for training (%):",
                  min = 30,
                  max = 80,
                  value = 50),
      checkboxGroupInput("variable",
                         label = "Select predictors:",
                         choices = list("Year" = "year",
                                        "Age" = "age",
                                        "Sex" = "sex",
                                        "Marital Status" = "maritl",
                                        "Race" = "race",
                                        "Education" = "education",
                                        "Region" = "region",
                                        "Job Class" = "jobclass",
                                        "Health" = "health",
                                        "Health Insurance" = "health_ins"),
                         selected = c("education", "race", "jobclass")),
      selectInput("method", label = "Select training model:",
                  choices = list("Linear" = "glm", "Random forests (cross validation)" = "rf_cv",
                                 "Random forests (boostrap)" = "rf_boot","Boosting" = "gbm"),
                  selected = "glm"),
      submitButton("Submit")
    ),
    
    # Show training and predicting results
    mainPanel(
      tabsetPanel(
        tabPanel("Prediction", plotOutput("pred"),h3("Training RMSE:"),textOutput("train_rmse"),
                 h3("Testing RMSE:"), textOutput("test_rmse")),
        tabPanel("Summary", verbatimTextOutput("summary")),
        tabPanel("Final Model", verbatimTextOutput("finalSummary"),
                 fluidRow(splitLayout(cellWidths = c("50%", "50%"),
                          plotOutput("finMod"), plotOutput("Mod"))))
      )
    )
  )
))
