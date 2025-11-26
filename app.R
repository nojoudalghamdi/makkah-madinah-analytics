library(shiny)
library(shinythemes)
library(sf)
library(ggplot2)
library(dplyr)
library(terra)
library(rnaturalearth)
library(plotly)
library(leaflet)
library(readxl)
library(geodata)
library(DT)
library(survey)

ui <- navbarPage(
  "Makkah-Madinah Analytics",
  
  # ===== TAB 1: OVERVIEW =====
  tabPanel("📋 Overview",
           div(class = "container-fluid",
               h1("Project Overview", style = "color: #4137a8;"),
               
               div(class = "well",
                   h3("About This Project"),
                   p("This dashboard provides comprehensive analytics for visitors to Makkah and Madinah using advanced data visualization techniques."),
                   p("Key features include:"),
                   tags$ul(
                     tags$li("Interactive maps showing regional visitor distribution"),
                     tags$li("Demographic analysis by age, gender, and nationality"),
                     tags$li("Real-time filtering and comparison tools"),
                     tags$li("Multi-language support (Arabic/English)"),
                     tags$li("Responsive design for all devices")
                   )
               ),
               
               div(class = "row",
                   div(class = "col-md-6",
                       div(class = "panel panel-primary",
                           div(class = "panel-heading", h4("Project Objectives")),
                           div(class = "panel-body",
                               tags$ul(
                                 tags$li("Analyze visitor patterns to holy cities"),
                                 tags$li("Understand demographic distributions"),
                                 tags$li("Provide insights for tourism planning"),
                                 tags$li("Support data-driven decision making")
                               )
                           )
                       )
                   ),
                   div(class = "col-md-6",
                       div(class = "panel panel-success", 
                           div(class = "panel-heading", h4("Technology Used")),
                           div(class = "panel-body",
                               tags$ul(
                                 tags$li("R Shiny - Interactive web framework"),
                                 tags$li("Plotly & ggplot2 - Data visualization"),
                                 tags$li("Leaflet - Interactive mapping"),
                                 tags$li("Power BI - Advanced analytics"),
                                 tags$li("Git & GitHub - Version control")
                               )
                           )
                       )
                   )
               ),
               
               div(class = "well well-lg",
                   h3("About the Developer"),
                   p("This project was developed as part of advanced data analytics portfolio, showcasing skills in:"),
                   tags$ul(
                     tags$li("Interactive dashboard development"),
                     tags$li("Data visualization and storytelling"),
                     tags$li("Spatial analysis and mapping"),
                     tags$li("Web application deployment")
                   ),
                   p("For more information or collaboration opportunities, please contact through GitHub.")
               )
           )
  ),
  
  # ===== TAB 2: R DASHBOARD =====
  tabPanel("📊 R Dashboard",
           fluidPage(
             theme = shinytheme("flatly"),
             tags$head(
               tags$style(HTML("
                 :root {
                   --primary-color: #4137a8;
                   --secondary-color: #7030A0;
                 }
                 .navbar-default .navbar-brand { color: white; }
                 .navbar { background-color: #4137a8; }
                 .navbar-default .navbar-nav > li > a { color: white; }
                 .stat-value {
                   font-size: 2.5em;
                   font-weight: bold;
                   text-align: center;
                 }
                 .stat-makkah { color: #4137a8; }
                 .stat-madinah { color: #27ced7; }
                 .stat-title {
                   font-size: 1.2em;
                   text-align: center;
                   margin-bottom: 10px;
                 }
                 .icon { font-size: 1.5em; margin-left: 5px; }
                 .calendar-special-container {
                   display: flex;
                   flex-direction: column;
                   gap: 10px;
                   padding: 10px;
                 }
                 .calendar-top-row, .calendar-bottom-row {
                   display: flex;
                   gap: 10px;
                   justify-content: center;
                 }
                 .calendar-month-box {
                   flex: 1;
                   padding: 15px;
                   border-radius: 10px;
                   color: white;
                   text-align: center;
                   min-height: 120px;
                   display: flex;
                   flex-direction: column;
                   justify-content: center;
                 }
                 .calendar-icon { font-size: 1.5em; margin-bottom: 5px; }
                 .calendar-month-name { font-weight: bold; font-size: 1.1em; }
                 .calendar-hijri-date { font-size: 0.8em; opacity: 0.9; margin: 5px 0; }
                 .calendar-stats { font-weight: bold; font-size: 1em; }
               "))
             ),
             
             navbarPage(
               "لوحة زائرين مكة والمدينة",
               id = "mainNav",
               
               # Summary Tab
               tabPanel(
                 "نظرة عامة",
                 sidebarLayout(
                   sidebarPanel(
                     width = 3,
                     style = "background-color: #f8f9fa; padding: 20px;",
                     h4("الفلاتر", style = "color: #4137a8;"),
                     selectInput("summary_gender_filter", "الجنس:",
                                 choices = c("الكل" = "All", "ذكر" = "ذكر", "أنثى" = "أنثى"),
                                 selected = "All"),
                     selectInput("summary_nationality_filter", "الجنسية:",
                                 choices = c("الكل" = "All", "سعودي" = "Saudi", "غير سعودي" = "Non-Saudi"),
                                 selected = "All"),
                     selectInput("summary_age_filter", "فئة العمر:",
                                 choices = c("الكل" = "All", "0-14" = "0-14", "15-24" = "15-24", 
                                             "25-34" = "25-34", "35-44" = "35-44", "45-54" = "45-54",
                                             "55-64" = "55-64", "65+" = "65+"),
                                 selected = "All"),
                     selectInput("comparison_type", "مقارنة حسب:",
                                 choices = c("الجنس" = "gender", "الجنسية" = "nationality", 
                                             "فئة العمر" = "age_group"),
                                 selected = "gender"),
                     actionButton("summary_reset_selection", "إعادة تعيين", 
                                  style = "background-color: #4137a8; color: white; width: 100%;")
                   ),
                   
                   mainPanel(
                     width = 9,
                     fluidRow(
                       column(12, 
                              h3(textOutput("summary_title"), 
                                 style = "text-align: center; color: #4137a8; margin-bottom: 20px;")
                       )
                     ),
                     
                     fluidRow(
                       column(4,
                              div(style = "background: white; padding: 20px; border-radius: 10px; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
                                  htmlOutput("makkah_visitors_stats")
                              )
                       ),
                       column(4,
                              div(style = "background: white; padding: 20px; border-radius: 10px; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
                                  htmlOutput("madinah_visitors_stats")
                              )
                       ),
                       column(4,
                              div(style = "background: white; padding: 20px; border-radius: 10px; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 100%;",
                                  h5("إجمالي المستجيبين", style = "color: #666;"),
                                  textOutput("total_respondents_display")
                              )
                       )
                     ),
                     
                     fluidRow(
                       column(12,
                              div(style = "margin: 20px 0;",
                                  leafletOutput("summary_map", height = "500px")
                              )
                       )
                     ),
                     
                     fluidRow(
                       column(12,
                              div(style = "background: #4137a8; padding: 20px; border-radius: 10px;",
                                  plotlyOutput("summary_comparison_chart", height = "300px")
                              )
                       )
                     )
                   )
                 )
               ),
               
               # Makkah Statistics Tab
               tabPanel(
                 "احصائيات زوار مكة",
                 sidebarLayout(
                   sidebarPanel(
                     width = 3,
                     style = "background-color: #f8f9fa; padding: 20px;",
                     h4("فلاتر مكة", style = "color: #4137a8;"),
                     selectInput("makkah_gender_filter", "الجنس:",
                                 choices = c("الكل" = "All", "ذكر" = "ذكر", "أنثى" = "أنثى"),
                                 selected = "All"),
                     selectInput("makkah_nationality_filter", "الجنسية:",
                                 choices = c("الكل" = "All", "سعودي" = "Saudi", "غير سعودي" = "Non-Saudi"),
                                 selected = "All"),
                     selectInput("makkah_age_filter", "فئة العمر:",
                                 choices = c("الكل" = "All", "0-14" = "0-14", "15-24" = "15-24", 
                                             "25-34" = "25-34", "35-44" = "35-44", "45-54" = "45-54",
                                             "55-64" = "55-64", "65+" = "65+"),
                                 selected = "All")
                   ),
                   
                   mainPanel(
                     width = 9,
                     fluidRow(
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("الرفقة أثناء العمرة", style = "color: #4137a8; text-align: center;"),
                                  plotlyOutput("makkah_companions_chart", height = "250px")
                              )
                       ),
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("أشهر العمرة", style = "color: #4137a8; text-align: center;"),
                                  uiOutput("makkah_calendar_display")
                              )
                       )
                     ),
                     
                     fluidRow(
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("وسيلة التنقل", style = "color: #4137a8; text-align: center;"),
                                  plotlyOutput("makkah_transport_chart", height = "250px")
                              )
                       ),
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("عدد ليالي المبيت", style = "color: #4137a8; text-align: center;"),
                                  plotlyOutput("makkah_nights_chart", height = "250px")
                              )
                       )
                     ),
                     
                     fluidRow(
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("نوع المسكن", style = "color: #4137a8; text-align: center;"),
                                  plotlyOutput("makkah_housing_chart", height = "250px")
                              )
                       ),
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("جهة الإنفاق", style = "color: #4137a8; text-align: center;"),
                                  plotlyOutput("makkah_sponsor_chart", height = "250px")
                              )
                       )
                     )
                   )
                 )
               ),
               
               # Madinah Statistics Tab
               tabPanel(
                 "احصائيات زوار المدينة", 
                 sidebarLayout(
                   sidebarPanel(
                     width = 3,
                     style = "background-color: #f8f9fa; padding: 20px;",
                     h4("فلاتر المدينة", style = "color: #27ced7;"),
                     selectInput("madinah_gender_filter", "الجنس:",
                                 choices = c("الكل" = "All", "ذكر" = "ذكر", "أنثى" = "أنثى"),
                                 selected = "All"),
                     selectInput("madinah_nationality_filter", "الجنسية:",
                                 choices = c("الكل" = "All", "سعودي" = "Saudi", "غير سعودي" = "Non-Saudi"),
                                 selected = "All"),
                     selectInput("madinah_age_filter", "فئة العمر:",
                                 choices = c("الكل" = "All", "0-14" = "0-14", "15-24" = "15-24", 
                                             "25-34" = "25-34", "35-44" = "35-44", "45-54" = "45-54",
                                             "55-64" = "55-64", "65+" = "65+"),
                                 selected = "All")
                   ),
                   
                   mainPanel(
                     width = 9,
                     fluidRow(
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("الرفقة أثناء زيارة المدينة", style = "color: #27ced7; text-align: center;"),
                                  plotlyOutput("madinah_companions_chart", height = "250px")
                              )
                       ),
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("أشهر زيارة المدينة", style = "color: #27ced7; text-align: center;"),
                                  uiOutput("madinah_calendar_display")
                              )
                       )
                     ),
                     
                     fluidRow(
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("وسيلة التنقل", style = "color: #27ced7; text-align: center;"),
                                  plotlyOutput("madinah_transport_chart", height = "250px")
                              )
                       ),
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("عدد ليالي المبيت", style = "color: #27ced7; text-align: center;"),
                                  plotlyOutput("madinah_nights_chart", height = "250px")
                              )
                       )
                     ),
                     
                     fluidRow(
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("نوع المسكن", style = "color: #27ced7; text-align: center;"),
                                  plotlyOutput("madinah_housing_chart", height = "250px")
                              )
                       ),
                       column(6,
                              div(style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); height: 300px;",
                                  h5("جهة الإنفاق", style = "color: #27ced7; text-align: center;"),
                                  plotlyOutput("madinah_sponsor_chart", height = "250px")
                              )
                       )
                     )
                   )
                 )
               )
             )
           )
  ),
  
  # ===== TAB 3: POWER BI =====
  tabPanel("📈 Power BI",
           div(class = "container-fluid",
               h1("Power BI Dashboard", style = "color: #4137a8;"),
               
               # ✏️ REPLACE THIS URL WITH YOUR ACTUAL POWER BI LINK
               div(class = "alert alert-info",
                   h4("Power BI Integration"),
                   p("This section is configured to display embedded Power BI reports."),
                   p("To add your Power BI dashboard:"),
                   tags$ol(
                     tags$li("Publish your Power BI report to Power BI Service"),
                     tags$li("Get the embed URL from Power BI"),
                     tags$li("Replace the URL in the server code with your actual Power BI URL")
                   )
               ),
               
               # This will be dynamically rendered from the server
               uiOutput("powerbi_frame")
           )
  )
)

server <- function(input, output, session) {
  
  # Reactive values for selections
  selected_region <- reactiveVal(NULL)
  
  # Enhanced sample data generator
  tourism_data <- reactive({
    set.seed(123)
    n <- 1500
    
    df <- data.frame(
      sample_id = 1:n,
      q101_umrah = sample(c("Yes", "No"), n, replace = TRUE, prob = c(0.75, 0.25)),
      q301_medina = sample(c("Yes", "No"), n, replace = TRUE, prob = c(0.65, 0.35)),
      c.comp_gender = sample(c("ذكر", "أنثى"), n, replace = TRUE, prob = c(0.52, 0.48)),
      citizenship = sample(c("Saudi", "Non-Saudi"), n, replace = TRUE, prob = c(0.85, 0.15)),
      c.comp_age = sample(18:75, n, replace = TRUE, prob = dnorm(18:75, mean = 45, sd = 15)),
      c.admin_name = sample(c("مكة المكرمة", "المدينة المنورة", "الرياض", "المنطقة الشرقية", 
                              "القصيم", "عسير", "تبوك", "حائل", "جازان"), n, replace = TRUE,
                            prob = c(0.25, 0.20, 0.15, 0.12, 0.08, 0.07, 0.06, 0.04, 0.03)),
      c.q201 = sample(c("مع العائلة", "فردي", "مع الأصدقاء"), n, replace = TRUE, 
                      prob = c(0.65, 0.20, 0.15)),
      c.q205_umrah_month = sample(c("ابريل", "مايو", "يونيو", "يوليو", "اغسطس"), n, replace = TRUE,
                                  prob = c(0.15, 0.25, 0.30, 0.20, 0.10)),
      c.q206_umrah_transport = sample(c("سيارة خاصة", "حافلة", "قطار", "طائرة", "سيارة اجرة"), n, replace = TRUE,
                                      prob = c(0.45, 0.25, 0.15, 0.10, 0.05)),
      c.q207_umrah_nights = sample(c("1", "2", "3", "4"), n, replace = TRUE, 
                                   prob = c(0.10, 0.25, 0.40, 0.25)),
      c.q208_umrah_housing = sample(c("الفنادق", "الشقق الفندقية", "الشقق المخدموة", "مسكن خاص", "مسكن لدى الأقارب او الأصدقاء"), n, replace = TRUE,
                                    prob = c(0.35, 0.25, 0.15, 0.15, 0.10)),
      c.q209_umrah_sponser = sample(c("حساب شخصي أو الاسرة", "جمعية خيرية", "جهات حكومية"), n, replace = TRUE,
                                    prob = c(0.70, 0.20, 0.10)),
      c.q402_med_companions = sample(c("مع العائلة", "فردي", "مع الأصدقاء"), n, replace = TRUE, 
                                     prob = c(0.60, 0.25, 0.15)),
      c.q406_med_month = sample(c("ابريل", "مايو", "يونيو", "يوليو", "اغسطس"), n, replace = TRUE,
                                prob = c(0.20, 0.30, 0.25, 0.15, 0.10)),
      c.q407_med_transport = sample(c("سيارة خاصة", "حافلة", "قطار", "طائرة", "سيارة اجرة", "مركبة مستآجرة"), n, replace = TRUE,
                                    prob = c(0.40, 0.20, 0.15, 0.10, 0.10, 0.05)),
      c.q408_med_nights = sample(c("1", "2", "3", "4"), n, replace = TRUE, 
                                 prob = c(0.15, 0.35, 0.35, 0.15)),
      c.q409_med_housing = sample(c("الفنادق", "الشقق الفندقية", "الشقق المخدومة", "مسكن خاص", "مسكن لدى الأقارب او الأصدقاء"), n, replace = TRUE,
                                  prob = c(0.30, 0.25, 0.20, 0.15, 0.10)),
      c.q410_med_sponser = sample(c("حساب شخصي أو الاسرة", "جمعية خيرية"), n, replace = TRUE,
                                  prob = c(0.80, 0.20))
    )
    
    # Process data
    df$makkah_visit <- ifelse(tolower(df$q101_umrah) == "yes", 1, 0)
    df$madinah_visit <- ifelse(tolower(df$q301_medina) == "yes", 1, 0)
    df$all_visitors <- ifelse(df$makkah_visit == 1 | df$madinah_visit == 1, 1, 0)
    df$gender_ar <- df$c.comp_gender
    df$nationality <- df$citizenship
    df$nationality_ar <- ifelse(df$citizenship == "Saudi", "سعودي", "غير سعودي")
    
    df <- df %>%
      mutate(
        age_group = case_when(
          as.numeric(c.comp_age) <= 14 ~ "0-14",
          as.numeric(c.comp_age) <= 24 ~ "15-24", 
          as.numeric(c.comp_age) <= 34 ~ "25-34",
          as.numeric(c.comp_age) <= 44 ~ "35-44",
          as.numeric(c.comp_age) <= 54 ~ "45-54",
          as.numeric(c.comp_age) <= 64 ~ "55-64",
          TRUE ~ "65+"
        )
      )
    
    df$region <- df$c.admin_name
    df$companions <- df$c.q201
    df$umrah_month <- case_when(
      df$c.q205_umrah_month == "ابريل" ~ "ابريل (April)",
      df$c.q205_umrah_month == "مايو" ~ "مايو (May)", 
      df$c.q205_umrah_month == "يونيو" ~ "يونيو (June)",
      df$c.q205_umrah_month == "يوليو" ~ "يوليو (July)",
      df$c.q205_umrah_month == "اغسطس" ~ "أغسطس (August)",
      TRUE ~ "غير محدد"
    )
    df$transport <- df$c.q206_umrah_transport
    df$nights <- case_when(
      df$c.q207_umrah_nights == "1" ~ "لم يبت",
      df$c.q207_umrah_nights == "2" ~ "ليلة واحدة", 
      df$c.q207_umrah_nights == "3" ~ "ليلتان",
      df$c.q207_umrah_nights == "4" ~ "ثلاث ليالٍ",
      TRUE ~ "غير محدد"
    )
    df$housing <- df$c.q208_umrah_housing
    df$sponsor <- df$c.q209_umrah_sponser
    df$med_companions <- df$c.q402_med_companions
    df$med_month <- case_when(
      df$c.q406_med_month == "ابريل" ~ "ابريل (April)",
      df$c.q406_med_month == "مايو" ~ "مايو (May)",
      df$c.q406_med_month == "يونيو" ~ "يونيو (June)", 
      df$c.q406_med_month == "يوليو" ~ "يوليو (July)",
      df$c.q406_med_month == "اغسطس" ~ "أغسطس (August)",
      TRUE ~ "غير محدد"
    )
    df$med_transport <- df$c.q407_med_transport
    df$med_nights <- case_when(
      df$c.q408_med_nights == "1" ~ "لم يبت",
      df$c.q408_med_nights == "2" ~ "ليلة واحدة",
      df$c.q408_med_nights == "3" ~ "ليلتان",
      df$c.q408_med_nights == "4" ~ "ثلاث ليالٍ", 
      TRUE ~ "غير محدد"
    )
    df$med_housing <- df$c.q409_med_housing
    df$med_sponsor <- df$c.q410_med_sponser
    
    return(df)
  })
  
  # Power BI Frame
  output$powerbi_frame <- renderUI({
    tags$iframe(
      width = "100%", 
      height = "800",
      src = "https://app.powerbi.com/view?r=YOUR_ACTUAL_POWER_BI_URL_HERE",
      frameborder = "0",
      allowfullscreen = "true"
    )
  })
  
  # [REST OF YOUR SERVER CODE - ALL YOUR EXISTING CHART FUNCTIONS]
  # Filter data for Makkah tab
  filtered_makkah_data <- reactive({
    data <- tourism_data() %>% filter(makkah_visit == 1)
    
    if (input$makkah_gender_filter != "All") {
      data <- data %>% filter(gender_ar == input$makkah_gender_filter)
    }
    
    if (input$makkah_nationality_filter != "All") {
      data <- data %>% filter(nationality == input$makkah_nationality_filter)
    }
    
    if (input$makkah_age_filter != "All") {
      data <- data %>% filter(age_group == input$makkah_age_filter)
    }
    
    data
  })
  
  # Filter data for Madinah tab
  filtered_madinah_data <- reactive({
    data <- tourism_data() %>% filter(madinah_visit == 1)
    
    if (input$madinah_gender_filter != "All") {
      data <- data %>% filter(gender_ar == input$madinah_gender_filter)
    }
    
    if (input$madinah_nationality_filter != "All") {
      data <- data %>% filter(nationality == input$madinah_nationality_filter)
    }
    
    if (input$madinah_age_filter != "All") {
      data <- data %>% filter(age_group == input$madinah_age_filter)
    }
    
    data
  })
  
  # [ALL YOUR EXISTING CHART OUTPUTS - MAKKAH CHARTS, MADINAH CHARTS, SUMMARY TAB CODE]
  # MAKKAH CHARTS
  output$makkah_companions_chart <- renderPlotly({
    data <- filtered_makkah_data()
    
    if (nrow(data) > 0) {
      plot_data <- data %>%
        filter(!is.na(companions) & companions != "غير محدد") %>%
        count(companions) %>%
        mutate(percent = (n / sum(n)) * 100)
      
      if (nrow(plot_data) > 0) {
        plot_ly(plot_data, labels = ~companions, values = ~n, type = 'pie',
                textinfo = 'percent+label',
                hoverinfo = 'text',
                hovertext = ~paste0(companions, ": ", n, " (", round(percent, 1), "%)"),
                marker = list(colors = c('#4137a8', '#27ced7', '#ffc000'))) %>%
          layout(
            showlegend = FALSE,
            margin = list(l = 10, r = 10, b = 10, t = 10),
            paper_bgcolor = 'rgba(0,0,0,0)',
            plot_bgcolor = 'rgba(0,0,0,0)'
          )
      } else {
        plot_ly() %>%
          add_annotations(text = "لا توجد بيانات",
                          xref = "paper", yref = "paper",
                          x = 0.5, y = 0.5, showarrow = FALSE) %>%
          layout(paper_bgcolor = 'rgba(0,0,0,0)',
                 plot_bgcolor = 'rgba(0,0,0,0)')
      }
    } else {
      plot_ly() %>%
        add_annotations(text = "لا توجد بيانات",
                        xref = "paper", yref = "paper",
                        x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(paper_bgcolor = 'rgba(0,0,0,0)',
               plot_bgcolor = 'rgba(0,0,0,0)')
    }
  })
  
  output$makkah_calendar_display <- renderUI({
    data <- filtered_makkah_data()
    
    total_visitors <- if (nrow(data) > 0) nrow(data) else 0
    
    april_count <- if (total_visitors > 0) sum(grepl("ابريل", data$c.q205_umrah_month, ignore.case = TRUE), na.rm = TRUE) else 0
    may_count <- if (total_visitors > 0) sum(grepl("مايو", data$c.q205_umrah_month, ignore.case = TRUE), na.rm = TRUE) else 0
    june_count <- if (total_visitors > 0) sum(grepl("يونيو", data$c.q205_umrah_month, ignore.case = TRUE), na.rm = TRUE) else 0
    
    april_percent <- if (total_visitors > 0) (april_count / total_visitors) * 100 else 0
    may_percent <- if (total_visitors > 0) (may_count / total_visitors) * 100 else 0
    june_percent <- if (total_visitors > 0) (june_count / total_visitors) * 100 else 0
    
    div(class = "calendar-special-container",
        div(class = "calendar-top-row",
            div(class = "calendar-month-box",
                style = "background: linear-gradient(135deg, #4137a8, #7030A0);",
                div(class = "calendar-icon", "📅"),
                div(class = "calendar-month-name", "أبريل"),
                div(class = "calendar-hijri-date", "3 شوال - 2 ذو القعدة 1446هـ"),
                div(class = "calendar-stats", paste0(april_count, " (", round(april_percent, 1), "%)"))
            ),
            div(class = "calendar-month-box",
                style = "background: linear-gradient(135deg, #27ced7, #7030A0);",
                div(class = "calendar-icon", "📅"),
                div(class = "calendar-month-name", "مايو"),
                div(class = "calendar-hijri-date", "3 ذو القعدة - 4 ذو الحجة 1446هـ"),
                div(class = "calendar-stats", paste0(may_count, " (", round(may_percent, 1), "%)"))
            )
        ),
        div(class = "calendar-bottom-row",
            div(class = "calendar-month-box",
                style = "background: linear-gradient(135deg, #ffc000, #7030A0);",
                div(class = "calendar-icon", "📅"),
                div(class = "calendar-month-name", "يونيو"),
                div(class = "calendar-hijri-date", "5 ذو الحجة - 5 محرم 1447هـ"),
                div(class = "calendar-stats", paste0(june_count, " (", round(june_percent, 1), "%)"))
            )
        )
    )
  })
  
  # C - وسيلة التنقل لرحلة العمرة
  output$makkah_transport_chart <- renderPlotly({
    data <- filtered_makkah_data()
    
    if (nrow(data) > 0) {
      plot_data <- data %>%
        filter(!is.na(transport) & transport != "غير محدد") %>%
        count(transport) %>%
        mutate(percent = (n / sum(n)) * 100)
      
      if (nrow(plot_data) > 0) {
        plot_ly(plot_data, x = ~transport, y = ~n, type = 'bar',
                marker = list(color = '#1cade4'),
                text = ~paste0(n, " (", round(percent, 1), "%)"),
                textposition = 'auto',
                hoverinfo = 'text',
                hovertext = ~paste0(
                  "وسيلة التنقل: ", transport, "<br>",
                  "العدد: ", n, "<br>",
                  "النسبة: ", round(percent, 1), "%"
                )) %>%
          layout(
            xaxis = list(title = "", tickangle = -45),
            yaxis = list(title = "عدد الزوار"),
            margin = list(l = 50, r = 20, b = 100, t = 20),
            paper_bgcolor = 'rgba(0,0,0,0)',
            plot_bgcolor = 'rgba(0,0,0,0)'
          )
      } else {
        plot_ly() %>%
          add_annotations(text = "لا توجد بيانات",
                          xref = "paper", yref = "paper",
                          x = 0.5, y = 0.5, showarrow = FALSE) %>%
          layout(paper_bgcolor = 'rgba(0,0,0,0)',
                 plot_bgcolor = 'rgba(0,0,0,0)')
      }
    } else {
      plot_ly() %>%
        add_annotations(text = "لا توجد بيانات",
                        xref = "paper", yref = "paper",
                        x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(paper_bgcolor = 'rgba(0,0,0,0)',
               plot_bgcolor = 'rgba(0,0,0,0)')
    }
  })
  
  # D - عدد ليالي المبيت في مكة المكرمة
  output$makkah_nights_chart <- renderPlotly({
    data <- filtered_makkah_data()
    
    if (nrow(data) > 0) {
      plot_data <- data %>%
        filter(!is.na(nights) & nights != "غير محدد") %>%
        count(nights) %>%
        mutate(percent = (n / sum(n)) * 100)
      
      if (nrow(plot_data) > 0) {
        # Order the nights properly
        nights_order <- c("لم يبت", "ليلة واحدة", "ليلتان", "ثلاث ليالٍ")
        plot_data$nights <- factor(plot_data$nights, levels = nights_order)
        plot_data <- plot_data[order(plot_data$nights), ]
        
        plot_ly(plot_data, x = ~nights, y = ~n, type = 'bar',
                marker = list(color = '#9A66D1'),
                text = ~paste0(n, " (", round(percent, 1), "%)"),
                textposition = 'auto',
                hoverinfo = 'text',
                hovertext = ~paste0(
                  "عدد الليالي: ", nights, "<br>",
                  "العدد: ", n, "<br>",
                  "النسبة: ", round(percent, 1), "%"
                )) %>%
          layout(
            xaxis = list(title = ""),
            yaxis = list(title = "عدد الزوار"),
            margin = list(l = 50, r = 20, b = 80, t = 20),
            paper_bgcolor = 'rgba(0,0,0,0)',
            plot_bgcolor = 'rgba(0,0,0,0)'
          )
      } else {
        plot_ly() %>%
          add_annotations(text = "لا توجد بيانات",
                          xref = "paper", yref = "paper",
                          x = 0.5, y = 0.5, showarrow = FALSE) %>%
          layout(paper_bgcolor = 'rgba(0,0,0,0)',
                 plot_bgcolor = 'rgba(0,0,0,0)')
      }
    } else {
      plot_ly() %>%
        add_annotations(text = "لا توجد بيانات",
                        xref = "paper", yref = "paper",
                        x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(paper_bgcolor = 'rgba(0,0,0,0)',
               plot_bgcolor = 'rgba(0,0,0,0)')
    }
  })
  
  # E - نوع المسكن لرحلة العمرة (Bar Chart)
  output$makkah_housing_chart <- renderPlotly({
    data <- filtered_makkah_data()
    
    if (nrow(data) > 0) {
      plot_data <- data %>%
        filter(!is.na(housing) & housing != "غير محدد") %>%
        count(housing) %>%
        mutate(percent = (n / sum(n)) * 100)
      
      if (nrow(plot_data) > 0) {
        plot_ly(plot_data, x = ~housing, y = ~n, type = 'bar',
                marker = list(color = '#ffc000'),
                text = ~paste0(n, " (", round(percent, 1), "%)"),
                textposition = 'auto',
                hoverinfo = 'text',
                hovertext = ~paste0(
                  "نوع المسكن: ", housing, "<br>",
                  "العدد: ", n, "<br>",
                  "النسبة: ", round(percent, 1), "%"
                )) %>%
          layout(
            xaxis = list(title = "", tickangle = -45, tickfont = list(size = 10)),
            yaxis = list(title = "عدد الزوار"),
            margin = list(l = 50, r = 20, b = 100, t = 20),
            paper_bgcolor = 'rgba(0,0,0,0)',
            plot_bgcolor = 'rgba(0,0,0,0)'
          )
      } else {
        plot_ly() %>%
          add_annotations(text = "لا توجد بيانات",
                          xref = "paper", yref = "paper",
                          x = 0.5, y = 0.5, showarrow = FALSE) %>%
          layout(paper_bgcolor = 'rgba(0,0,0,0)',
                 plot_bgcolor = 'rgba(0,0,0,0)')
      }
    } else {
      plot_ly() %>%
        add_annotations(text = "لا توجد بيانات",
                        xref = "paper", yref = "paper",
                        x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(paper_bgcolor = 'rgba(0,0,0,0)',
               plot_bgcolor = 'rgba(0,0,0,0)')
    }
  })
  
  # F - تحمل تكاليف أداء مناسك العمرة (Pie Chart)
  output$makkah_sponsor_chart <- renderPlotly({
    data <- filtered_makkah_data()
    
    if (nrow(data) > 0) {
      plot_data <- data %>%
        filter(!is.na(sponsor) & sponsor != "غير محدد") %>%
        count(sponsor) %>%
        mutate(percent = (n / sum(n)) * 100)
      
      if (nrow(plot_data) > 0) {
        plot_ly(plot_data, labels = ~sponsor, values = ~n, type = 'pie',
                textinfo = 'none',
                hoverinfo = 'label+percent+value',
                hovertext = ~paste0(sponsor, "\n", n, " زائر (", round(percent, 1), "%)"),
                marker = list(colors = c('#4137a8', '#27ced7', '#ffc000')),
                hole = 0.5,
                textposition = 'none') %>%
          layout(
            showlegend = TRUE,
            legend = list(
              orientation = 'v',
              x = 0.8,
              y = 0.5,
              font = list(size = 9)
            ),
            margin = list(l = 5, r = 5, b = 5, t = 5, pad = 2),
            paper_bgcolor = 'rgba(0,0,0,0)',
            plot_bgcolor = 'rgba(0,0,0,0)'
          )
      } else {
        plot_ly() %>%
          add_annotations(text = "لا توجد بيانات",
                          xref = "paper", yref = "paper",
                          x = 0.5, y = 0.5, showarrow = FALSE) %>%
          layout(paper_bgcolor = 'rgba(0,0,0,0)',
                 plot_bgcolor = 'rgba(0,0,0,0)')
      }
    } else {
      plot_ly() %>%
        add_annotations(text = "لا توجد بيانات",
                        xref = "paper", yref = "paper",
                        x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(paper_bgcolor = 'rgba(0,0,0,0)',
               plot_bgcolor = 'rgba(0,0,0,0)')
    }
  })
  
  # MADINAH CHARTS
  # A - المرافقين في رحلة المدينة المنورة
  output$madinah_companions_chart <- renderPlotly({
    data <- filtered_madinah_data()
    
    if (nrow(data) > 0) {
      plot_data <- data %>%
        filter(!is.na(med_companions) & med_companions != "غير محدد") %>%
        count(med_companions) %>%
        mutate(percent = (n / sum(n)) * 100)
      
      if (nrow(plot_data) > 0) {
        plot_ly(plot_data, labels = ~med_companions, values = ~n, type = 'pie',
                textinfo = 'percent+label',
                hoverinfo = 'text',
                hovertext = ~paste0(med_companions, ": ", n, " (", round(percent, 1), "%)"),
                marker = list(colors = c('#4137a8', '#27ced7', '#ffc000'))) %>%
          layout(
            showlegend = FALSE,
            margin = list(l = 10, r = 10, b = 10, t = 10),
            paper_bgcolor = 'rgba(0,0,0,0)',
            plot_bgcolor = 'rgba(0,0,0,0)'
          )
      } else {
        plot_ly() %>%
          add_annotations(text = "لا توجد بيانات",
                          xref = "paper", yref = "paper",
                          x = 0.5, y = 0.5, showarrow = FALSE) %>%
          layout(paper_bgcolor = 'rgba(0,0,0,0)',
                 plot_bgcolor = 'rgba(0,0,0,0)')
      }
    } else {
      plot_ly() %>%
        add_annotations(text = "لا توجد بيانات",
                        xref = "paper", yref = "paper",
                        x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(paper_bgcolor = 'rgba(0,0,0,0)',
               plot_bgcolor = 'rgba(0,0,0,0)')
    }
  })
  
  # B - الزيارة حسب الأشهر (Calendar display)
  output$madinah_calendar_display <- renderUI({
    data <- filtered_madinah_data()
    
    # Define all months
    calendar_months <- list(
      list(arabic = "أبريل", search_term = "ابريل", hijri = "3 شوال - 2 ذو القعدة 1446هـ", color = "#4137a8"),
      list(arabic = "مايو", search_term = "مايو", hijri = "3 ذو القعدة - 4 ذو الحجة 1446هـ", color = "#27ced7"),
      list(arabic = "يونيو", search_term = "يونيو", hijri = "5 ذو الحجة - 5 محرم 1447هـ", color = "#ffc000")
    )
    
    # Calculate visitor counts for each month
    total_visitors <- if (nrow(data) > 0) nrow(data) else 0
    
    # Count visitors for each month
    april_count <- if (total_visitors > 0) sum(grepl("ابريل", data$c.q406_med_month, ignore.case = TRUE), na.rm = TRUE) else 0
    may_count <- if (total_visitors > 0) sum(grepl("مايو", data$c.q406_med_month, ignore.case = TRUE), na.rm = TRUE) else 0
    june_count <- if (total_visitors > 0) sum(grepl("يونيو", data$c.q406_med_month, ignore.case = TRUE), na.rm = TRUE) else 0
    
    # Calculate percentages
    april_percent <- if (total_visitors > 0) (april_count / total_visitors) * 100 else 0
    may_percent <- if (total_visitors > 0) (may_count / total_visitors) * 100 else 0
    june_percent <- if (total_visitors > 0) (june_count / total_visitors) * 100 else 0
    
    # Create calendar layout
    div(class = "calendar-special-container",
        # Top row - 2 boxes side by side
        div(class = "calendar-top-row",
            # April box
            div(class = "calendar-month-box",
                style = "background: linear-gradient(135deg, #4137a8, #7030A0);",
                div(class = "calendar-icon", "📅"),
                div(class = "calendar-month-name", "أبريل"),
                div(class = "calendar-hijri-date", "3 شوال - 2 ذو القعدة 1446هـ"),
                div(class = "calendar-stats", paste0(april_count, " (", round(april_percent, 1), "%)"))
            ),
            # May box
            div(class = "calendar-month-box",
                style = "background: linear-gradient(135deg, #27ced7, #7030A0);",
                div(class = "calendar-icon", "📅"),
                div(class = "calendar-month-name", "مايو"),
                div(class = "calendar-hijri-date", "3 ذو القعدة - 4 ذو الحجة 1446هـ"),
                div(class = "calendar-stats", paste0(may_count, " (", round(may_percent, 1), "%)"))
            )
        ),
        # Bottom row - 1 box centered
        div(class = "calendar-bottom-row",
            div(class = "calendar-month-box",
                style = "background: linear-gradient(135deg, #ffc000, #7030A0);",
                div(class = "calendar-icon", "📅"),
                div(class = "calendar-month-name", "يونيو"),
                div(class = "calendar-hijri-date", "5 ذو الحجة - 5 محرم 1447هـ"),
                div(class = "calendar-stats", paste0(june_count, " (", round(june_percent, 1), "%)"))
            )
        )
    )
  })
  
  # C - وسيلة التنقل لرحلة المدينة المنورة
  output$madinah_transport_chart <- renderPlotly({
    data <- filtered_madinah_data()
    
    if (nrow(data) > 0) {
      plot_data <- data %>%
        filter(!is.na(med_transport) & med_transport != "غير محدد") %>%
        count(med_transport) %>%
        mutate(percent = (n / sum(n)) * 100)
      
      if (nrow(plot_data) > 0) {
        plot_ly(plot_data, x = ~med_transport, y = ~n, type = 'bar',
                marker = list(color = '#1cade4'),
                text = ~paste0(n, " (", round(percent, 1), "%)"),
                textposition = 'auto',
                hoverinfo = 'text',
                hovertext = ~paste0(
                  "وسيلة التنقل: ", med_transport, "<br>",
                  "العدد: ", n, "<br>",
                  "النسبة: ", round(percent, 1), "%"
                )) %>%
          layout(
            xaxis = list(title = "", tickangle = -45),
            yaxis = list(title = "عدد الزوار"),
            margin = list(l = 50, r = 20, b = 100, t = 20),
            paper_bgcolor = 'rgba(0,0,0,0)',
            plot_bgcolor = 'rgba(0,0,0,0)'
          )
      } else {
        plot_ly() %>%
          add_annotations(text = "لا توجد بيانات",
                          xref = "paper", yref = "paper",
                          x = 0.5, y = 0.5, showarrow = FALSE) %>%
          layout(paper_bgcolor = 'rgba(0,0,0,0)',
                 plot_bgcolor = 'rgba(0,0,0,0)')
      }
    } else {
      plot_ly() %>%
        add_annotations(text = "لا توجد بيانات",
                        xref = "paper", yref = "paper",
                        x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(paper_bgcolor = 'rgba(0,0,0,0)',
               plot_bgcolor = 'rgba(0,0,0,0)')
    }
  })
  
  # D - عدد ليالي المبيت في المدينة المنورة
  output$madinah_nights_chart <- renderPlotly({
    data <- filtered_madinah_data()
    
    if (nrow(data) > 0) {
      plot_data <- data %>%
        filter(!is.na(med_nights) & med_nights != "غير محدد") %>%
        count(med_nights) %>%
        mutate(percent = (n / sum(n)) * 100)
      
      if (nrow(plot_data) > 0) {
        # Order the nights properly
        nights_order <- c("لم يبت", "ليلة واحدة", "ليلتان", "ثلاث ليالٍ")
        plot_data$med_nights <- factor(plot_data$med_nights, levels = nights_order)
        plot_data <- plot_data[order(plot_data$med_nights), ]
        
        plot_ly(plot_data, x = ~med_nights, y = ~n, type = 'bar',
                marker = list(color = '#9A66D1'),
                text = ~paste0(n, " (", round(percent, 1), "%)"),
                textposition = 'auto',
                hoverinfo = 'text',
                hovertext = ~paste0(
                  "عدد الليالي: ", med_nights, "<br>",
                  "العدد: ", n, "<br>",
                  "النسبة: ", round(percent, 1), "%"
                )) %>%
          layout(
            xaxis = list(title = ""),
            yaxis = list(title = "عدد الزوار"),
            margin = list(l = 50, r = 20, b = 80, t = 20),
            paper_bgcolor = 'rgba(0,0,0,0)',
            plot_bgcolor = 'rgba(0,0,0,0)'
          )
      } else {
        plot_ly() %>%
          add_annotations(text = "لا توجد بيانات",
                          xref = "paper", yref = "paper",
                          x = 0.5, y = 0.5, showarrow = FALSE) %>%
          layout(paper_bgcolor = 'rgba(0,0,0,0)',
                 plot_bgcolor = 'rgba(0,0,0,0)')
      }
    } else {
      plot_ly() %>%
        add_annotations(text = "لا توجد بيانات",
                        xref = "paper", yref = "paper",
                        x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(paper_bgcolor = 'rgba(0,0,0,0)',
               plot_bgcolor = 'rgba(0,0,0,0)')
    }
  })
  
  # E - نوع المسكن لرحلة المدينة المنورة (Bar Chart)
  output$madinah_housing_chart <- renderPlotly({
    data <- filtered_madinah_data()
    
    if (nrow(data) > 0) {
      plot_data <- data %>%
        filter(!is.na(med_housing) & med_housing != "غير محدد") %>%
        count(med_housing) %>%
        mutate(percent = (n / sum(n)) * 100)
      
      if (nrow(plot_data) > 0) {
        plot_ly(plot_data, x = ~med_housing, y = ~n, type = 'bar',
                marker = list(color = '#ffc000'),
                text = ~paste0(n, " (", round(percent, 1), "%)"),
                textposition = 'auto',
                hoverinfo = 'text',
                hovertext = ~paste0(
                  "نوع المسكن: ", med_housing, "<br>",
                  "العدد: ", n, "<br>",
                  "النسبة: ", round(percent, 1), "%"
                )) %>%
          layout(
            xaxis = list(title = "", tickangle = -45, tickfont = list(size = 10)),
            yaxis = list(title = "عدد الزوار"),
            margin = list(l = 50, r = 20, b = 100, t = 20),
            paper_bgcolor = 'rgba(0,0,0,0)',
            plot_bgcolor = 'rgba(0,0,0,0)'
          )
      } else {
        plot_ly() %>%
          add_annotations(text = "لا توجد بيانات",
                          xref = "paper", yref = "paper",
                          x = 0.5, y = 0.5, showarrow = FALSE) %>%
          layout(paper_bgcolor = 'rgba(0,0,0,0)',
                 plot_bgcolor = 'rgba(0,0,0,0)')
      }
    } else {
      plot_ly() %>%
        add_annotations(text = "لا توجد بيانات",
                        xref = "paper", yref = "paper",
                        x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(paper_bgcolor = 'rgba(0,0,0,0)',
               plot_bgcolor = 'rgba(0,0,0,0)')
    }
  })
  
  # F - حمل تكاليف زيارة المدينة المنورة (Pie Chart)
  output$madinah_sponsor_chart <- renderPlotly({
    data <- filtered_madinah_data()
    
    if (nrow(data) > 0) {
      plot_data <- data %>%
        filter(!is.na(med_sponsor) & med_sponsor != "غير محدد") %>%
        count(med_sponsor) %>%
        mutate(percent = (n / sum(n)) * 100)
      
      if (nrow(plot_data) > 0) {
        plot_ly(plot_data, labels = ~med_sponsor, values = ~n, type = 'pie',
                textinfo = 'none',
                hoverinfo = 'label+percent+value',
                hovertext = ~paste0(med_sponsor, "\n", n, " زائر (", round(percent, 1), "%)"),
                marker = list(colors = c('#4137a8', '#27ced7')),
                hole = 0.5,
                textposition = 'none') %>%
          layout(
            showlegend = TRUE,
            legend = list(
              orientation = 'v',
              x = 0.8,
              y = 0.5,
              font = list(size = 9)
            ),
            margin = list(l = 5, r = 5, b = 5, t = 5, pad = 2),
            paper_bgcolor = 'rgba(0,0,0,0)',
            plot_bgcolor = 'rgba(0,0,0,0)'
          )
      } else {
        plot_ly() %>%
          add_annotations(text = "لا توجد بيانات",
                          xref = "paper", yref = "paper",
                          x = 0.5, y = 0.5, showarrow = FALSE) %>%
          layout(paper_bgcolor = 'rgba(0,0,0,0)',
                 plot_bgcolor = 'rgba(0,0,0,0)')
      }
    } else {
      plot_ly() %>%
        add_annotations(text = "لا توجد بيانات",
                        xref = "paper", yref = "paper",
                        x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(paper_bgcolor = 'rgba(0,0,0,0)',
               plot_bgcolor = 'rgba(0,0,0,0)')
    }
  })
  
  # [REST OF THE EXISTING SERVER CODE FOR SUMMARY TAB...]
  # Saudi regions map with Arabic names
  saudi_regions <- reactive({
    tryCatch({
      saudi <- geodata::gadm(country = "SAU", level = 1, path = tempdir())
      regions_sf <- st_as_sf(saudi)
      
      # Add Arabic region names
      regions_sf$NAME_1_AR <- c(
        "المنطقة الشرقية",
        "الحدود الشمالية", 
        "الجوف",
        "نجران",
        "عسير",
        "جازان", 
        "تبوك",
        "المدينة المنورة",
        "مكة المكرمة",
        "الرياض",
        "القصيم",
        "حائل",
        "الباحة"
      )
      
      regions_sf
    }, error = function(e) {
      message("Error loading map: ", e$message)
      # Create simple sf object with Arabic names
      st_sf(
        NAME_1_AR = c("مكة المكرمة", "المدينة المنورة", "الرياض", "المنطقة الشرقية", "القصيم", 
                      "عسير", "تبوك", "حائل", "الحدود الشمالية", "جازان", "نجران", "الجوف", "الباحة"),
        geometry = st_sfc(
          st_point(c(39.8, 21.4)), st_point(c(39.6, 24.5)), st_point(c(46.7, 24.7)),
          st_point(c(49.4, 26.4)), st_point(c(43.5, 26.3)), st_point(c(42.5, 19.1)),
          st_point(c(36.5, 28.5)), st_point(c(41.7, 27.5)), st_point(c(42.9, 30.0)),
          st_point(c(42.6, 17.0)), st_point(c(44.4, 17.5)), st_point(c(40.2, 29.8)),
          st_point(c(41.5, 20.0))
        )
      )
    })
  })
  
  # Filter data based on selections for Summary tab
  filtered_summary_data <- reactive({
    data <- tourism_data()
    
    # Apply gender filter
    if (input$summary_gender_filter != "All") {
      data <- data %>% filter(gender_ar == input$summary_gender_filter)
    }
    
    # Apply nationality filter
    if (input$summary_nationality_filter != "All") {
      data <- data %>% filter(nationality == input$summary_nationality_filter)
    }
    
    # Apply age filter
    if (input$summary_age_filter != "All") {
      data <- data %>% filter(age_group == input$summary_age_filter)
    }
    
    data
  })
  
  # Calculate visitor statistics - BASED ON WHOLE POPULATION
  calculate_visitor_stats <- function(data) {
    if (nrow(data) == 0) {
      return(list(
        makkah_percent = 0,
        madinah_percent = 0,
        all_visitors_percent = 0,
        makkah_count = 0,
        madinah_count = 0,
        all_visitors_count = 0,
        total_respondents = 0
      ))
    }
    
    total_respondents <- nrow(data)
    
    makkah_count <- sum(data$makkah_visit, na.rm = TRUE)
    madinah_count <- sum(data$madinah_visit, na.rm = TRUE)
    all_visitors_count <- sum(data$all_visitors, na.rm = TRUE)
    
    makkah_percent <- (makkah_count / total_respondents) * 100
    madinah_percent <- (madinah_count / total_respondents) * 100
    all_visitors_percent <- (all_visitors_count / total_respondents) * 100
    
    return(list(
      makkah_percent = makkah_percent,
      madinah_percent = madinah_percent,
      all_visitors_percent = all_visitors_percent,
      makkah_count = makkah_count,
      madinah_count = madinah_count,
      all_visitors_count = all_visitors_count,
      total_respondents = total_respondents
    ))
  }
  
  # Regional aggregated data for map - using visitor percentages
  regional_aggregated_data <- reactive({
    data <- filtered_summary_data()
    
    if (nrow(data) == 0) {
      return(data.frame())
    }
    
    # Calculate visitor statistics by region
    regional_stats <- data %>%
      group_by(region) %>%
      group_modify(~ {
        if (nrow(.x) > 0) {
          stats <- calculate_visitor_stats(.x)
          data.frame(
            makkah_percent = stats$makkah_percent,
            madinah_percent = stats$madinah_percent,
            all_visitors_percent = stats$all_visitors_percent,
            makkah_count = stats$makkah_count,
            madinah_count = stats$madinah_count,
            all_visitors_count = stats$all_visitors_count
          )
        } else {
          data.frame(
            makkah_percent = 0,
            madinah_percent = 0,
            all_visitors_percent = 0,
            makkah_count = 0,
            madinah_count = 0,
            all_visitors_count = 0
          )
        }
      }) %>%
      ungroup()
    
    regional_stats
  })
  
  # Current OVERALL stats for statistics boxes
  current_visitor_stats <- reactive({
    data <- filtered_summary_data()
    calculate_visitor_stats(data)
  })
  
  # Dynamic titles
  output$summary_title <- renderText({
    region <- selected_region()
    if (!is.null(region) && region != "") {
      paste("تحليل الزوار في", region)
    } else {
      "تحليل الزوار حسب المنطقة"
    }
  })
  
  # Render summary map - shows Makkah visitors percentage
  output$summary_map <- renderLeaflet({
    map_data_sf <- saudi_regions()
    regional_data <- regional_aggregated_data()
    
    # Create color palette for Makkah visitors percentage
    percentage_palette <- colorNumeric(
      palette = c("#9A66D1", "#7D4BA1", "#5A3585", "#4137A8"), 
      domain = c(0, 100),
      na.color = "#808080"
    )
    
    if (nrow(regional_data) > 0) {
      # Merge with regional data using Arabic names
      map_data_sf <- merge(map_data_sf, regional_data, by.x = "NAME_1_AR", by.y = "region", all.x = TRUE)
      
      # Create labels with percentages
      labels <- sprintf(
        "<strong>%s</strong><br/>
        زوار مكة: %.1f%%<br/>
        زوار المدينة: %.1f%%<br/>
        إجمالي الزوار: %.1f%%",
        map_data_sf$NAME_1_AR,
        ifelse(is.na(map_data_sf$makkah_percent), 0, map_data_sf$makkah_percent),
        ifelse(is.na(map_data_sf$madinah_percent), 0, map_data_sf$madinah_percent),
        ifelse(is.na(map_data_sf$all_visitors_percent), 0, map_data_sf$all_visitors_percent)
      ) %>% lapply(htmltools::HTML)
    } else {
      # Default labels when no data
      labels <- sprintf(
        "<strong>%s</strong><br/>لا توجد بيانات",
        map_data_sf$NAME_1_AR
      ) %>% lapply(htmltools::HTML)
    }
    
    leaflet(map_data_sf) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~percentage_palette(ifelse(is.na(makkah_percent), 0, makkah_percent)),
        fillOpacity = 0.7,
        color = "#444444",
        weight = 1,
        label = labels,
        layerId = ~NAME_1_AR,
        highlightOptions = highlightOptions(
          weight = 3,
          color = "#7D4BA1",
          fillOpacity = 0.8,
          bringToFront = TRUE
        )
      ) %>%
      addLegend(
        position = "bottomright",
        pal = percentage_palette,
        values = ~ifelse(is.na(makkah_percent), 0, makkah_percent),
        title = "زوار مكة %",
        opacity = 0.7,
        na.label = "لا توجد بيانات"
      ) %>%
      setView(lng = 45, lat = 24, zoom = 5)
  })
  
  # Handle map clicks
  observeEvent(input$summary_map_shape_click, {
    click <- input$summary_map_shape_click
    if (!is.null(click)) {
      selected_region(click$id)
      
      # Highlight the selected region
      leafletProxy("summary_map") %>%
        clearGroup("highlight") %>%
        addPolylines(
          data = saudi_regions()[saudi_regions()$NAME_1_AR == click$id, ],
          color = "#ffc000",
          weight = 4,
          group = "highlight"
        )
    }
  })
  
  # Statistics outputs for summary tab - VISITOR PERCENTAGES (WHOLE POPULATION)
  output$makkah_visitors_stats <- renderText({
    stats <- current_visitor_stats()
    
    paste0('<div class="stat-title"><span class="icon">🕋</span>زائرين مكة</div>',
           '<div class="stat-value stat-makkah">', 
           sprintf("%.1f%%", stats$makkah_percent), '</div>',
           '<div style="font-size: 10px; opacity: 0.8;">', stats$makkah_count, ' من ', stats$total_respondents, '</div>')
  })
  
  output$madinah_visitors_stats <- renderText({
    stats <- current_visitor_stats()
    
    paste0('<div class="stat-title"><span class="icon">🕌</span>زائرين المدينة</div>',
           '<div class="stat-value stat-madinah">', 
           sprintf("%.1f%%", stats$madinah_percent), '</div>',
           '<div style="font-size: 10px; opacity: 0.8;">', stats$madinah_count, ' من ', stats$total_respondents, '</div>')
  })
  
  # FIXED: Summary comparison chart with WHOLE POPULATION calculations
  output$summary_comparison_chart <- renderPlotly({
    data <- filtered_summary_data()
    
    if (nrow(data) > 0) {
      comparison_var <- input$comparison_type
      total_stats <- calculate_visitor_stats(data)
      
      if (comparison_var == "gender") {
        # Calculate distribution of ALL VISITORS across gender groups
        plot_data <- data %>%
          filter(all_visitors == 1) %>%  # Only look at visitors
          group_by(gender_ar) %>%
          summarise(
            count = n(),
            percent = (count / total_stats$all_visitors_count) * 100
          ) %>%
          filter(!is.na(gender_ar) & gender_ar != "غير محدد")
        
        if (nrow(plot_data) > 0) {
          plot_ly(plot_data, x = ~gender_ar, y = ~percent, type = 'bar',
                  marker = list(color = c('#ffc000', '#42ba97')),
                  text = ~paste0(round(percent, 1), "%"),
                  textposition = 'auto',
                  hoverinfo = 'text',
                  hovertext = ~paste0(
                    "الجنس: ", gender_ar, "<br>",
                    "النسبة: ", round(percent, 1), "%<br>",
                    "العدد: ", count, " زائر"
                  )) %>%
            layout(
              title = list(text = "توزيع الزوار حسب الجنس", 
                           font = list(color = 'white', size = 12)),
              xaxis = list(title = "", tickfont = list(color = 'white')),
              yaxis = list(title = "النسبة المئوية %", gridcolor = 'rgba(255,255,255,0.2)',
                           tickfont = list(color = 'white'), range = c(0, 100)),
              plot_bgcolor = 'transparent',
              paper_bgcolor = 'transparent',
              font = list(color = 'white')
            )
        } else {
          plot_ly() %>%
            add_annotations(text = "لا توجد بيانات للفلاتر المحددة",
                            xref = "paper", yref = "paper",
                            x = 0.5, y = 0.5, showarrow = FALSE,
                            font = list(color = 'white', size = 12)) %>%
            layout(
              plot_bgcolor = 'transparent',
              paper_bgcolor = 'transparent',
              font = list(color = 'white')
            )
        }
        
      } else if (comparison_var == "nationality") {
        # Calculate distribution of ALL VISITORS across nationality groups
        plot_data <- data %>%
          filter(all_visitors == 1) %>%  # Only look at visitors
          group_by(nationality_ar) %>%
          summarise(
            count = n(),
            percent = (count / total_stats$all_visitors_count) * 100
          ) %>%
          filter(!is.na(nationality_ar))
        
        if (nrow(plot_data) > 0) {
          plot_ly(plot_data, x = ~nationality_ar, y = ~percent, type = 'bar',
                  marker = list(color = c('#1cade4', '#27ced7')),
                  text = ~paste0(round(percent, 1), "%"),
                  textposition = 'auto',
                  hoverinfo = 'text',
                  hovertext = ~paste0(
                    "الجنسية: ", nationality_ar, "<br>",
                    "النسبة: ", round(percent, 1), "%<br>",
                    "العدد: ", count, " زائر"
                  )) %>%
            layout(
              title = list(text = "توزيع الزوار حسب الجنسية", 
                           font = list(color = 'white', size = 12)),
              xaxis = list(title = "", tickfont = list(color = 'white')),
              yaxis = list(title = "النسبة المئوية %", gridcolor = 'rgba(255,255,255,0.2)',
                           tickfont = list(color = 'white'), range = c(0, 100)),
              plot_bgcolor = 'transparent',
              paper_bgcolor = 'transparent',
              font = list(color = 'white')
            )
        } else {
          plot_ly() %>%
            add_annotations(text = "لا توجد بيانات للفلاتر المحددة",
                            xref = "paper", yref = "paper",
                            x = 0.5, y = 0.5, showarrow = FALSE,
                            font = list(color = 'white', size = 12)) %>%
            layout(
              plot_bgcolor = 'transparent',
              paper_bgcolor = 'transparent',
              font = list(color = 'white')
            )
        }
        
      } else if (comparison_var == "age_group") {
        # Calculate distribution of ALL VISITORS across age groups
        plot_data <- data %>%
          filter(all_visitors == 1) %>%  # Only look at visitors
          group_by(age_group) %>%
          summarise(
            count = n(),
            percent = (count / total_stats$all_visitors_count) * 100
          ) %>%
          filter(!is.na(age_group) & age_group != "غير محدد")
        
        if (nrow(plot_data) > 0) {
          plot_ly(plot_data, x = ~age_group, y = ~percent, type = 'bar',
                  marker = list(color = '#9A66D1'),
                  text = ~paste0(round(percent, 1), "%"),
                  textposition = 'auto',
                  hoverinfo = 'text',
                  hovertext = ~paste0(
                    "فئة العمر: ", age_group, "<br>",
                    "النسبة: ", round(percent, 1), "%<br>",
                    "العدد: ", count, " زائر"
                  )) %>%
            layout(
              title = list(text = "توزيع الزوار حسب فئة العمر", 
                           font = list(color = 'white', size = 12)),
              xaxis = list(title = "", tickfont = list(color = 'white')),
              yaxis = list(title = "النسبة المئوية %", gridcolor = 'rgba(255,255,255,0.2)',
                           tickfont = list(color = 'white'), range = c(0, 100)),
              plot_bgcolor = 'transparent',
              paper_bgcolor = 'transparent',
              font = list(color = 'white')
            )
        } else {
          plot_ly() %>%
            add_annotations(text = "لا توجد بيانات للفلاتر المحددة",
                            xref = "paper", yref = "paper",
                            x = 0.5, y = 0.5, showarrow = FALSE,
                            font = list(color = 'white', size = 12)) %>%
            layout(
              plot_bgcolor = 'transparent',
              paper_bgcolor = 'transparent',
              font = list(color = 'white')
            )
        }
      }
    } else {
      plot_ly() %>%
        add_annotations(text = "لا توجد بيانات للفلاتر المحددة",
                        xref = "paper", yref = "paper",
                        x = 0.5, y = 0.5, showarrow = FALSE,
                        font = list(color = 'white', size = 12)) %>%
        layout(
          plot_bgcolor = 'transparent',
          paper_bgcolor = 'transparent',
          font = list(color = 'white')
        )
    }
  })
  
  # Reset handlers
  observeEvent(input$summary_reset_selection, {
    selected_region(NULL)
    updateSelectInput(session, "summary_gender_filter", selected = "All")
    updateSelectInput(session, "summary_nationality_filter", selected = "All")
    updateSelectInput(session, "summary_age_filter", selected = "All")
    leafletProxy("summary_map") %>%
      clearGroup("highlight") %>%
      setView(lng = 45, lat = 24, zoom = 5)
  })
}

shinyApp(ui = ui, server = server)
  # ===== TAB 3: POWER BI =====
  tabPanel("📈 Power BI",
           div(class = "container-fluid",
               h1("Power BI Reports", style = "color: #4137a8;"),
               
               # ===== EDIT THIS SECTION =====
               # Option A: If you have Power BI reports
               tags$iframe(
                 width = "100%", 
                 height = "800",
                 src = "YOUR_POWER_BI_EMBED_URL_HERE",  # ← REPLACE THIS
                 frameborder = "0",
                 allowfullscreen = "true"
               ),
               
               # Option B: If you don't have Power BI yet
               div(class = "alert alert-info",
                   h4("Power BI Reports Coming Soon"),
                   p("This section will display embedded Power BI reports."),
                   p("To add your Power BI reports:"),
                   tags$ol(
                     tags$li("Publish your Power BI report to Power BI Service"),
                     tags$li("Get the embed URL"),
                     tags$li("Replace the URL in the code above")
                   )
               )
           )
  )
)

server <- function(input, output, session) {
  # ===== YOUR EXISTING SERVER CODE =====
  # Copy and paste your entire server code here
  # This handles all the dashboard functionality
  # Uses your generated data - NO CHANGES NEEDED
}

shinyApp(ui, server)