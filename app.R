library(shiny)
library(genius)
library(tidytext)
library(purrr)
library(ggplot2)
library(plotly)
library(corpus)
library(DT)
library(tm)
library(shinydashboard)
library(webshot)
library(wordcloud)

nrc <- get_sentiments("nrc") #define the lexicon used for the sentimental analysis, here we chose the NRC one
webshot::install_phantomjs() #might launch this line of code before running the app if the album cover doesn't show up


get_album_sentiments <- function(artist, album){  
  df <- genius_album(artist = artist, album = album) #scrape with genius package
  df <- df[, -c(2:3)] #take out unnecessary columns
  df$lyric_stem <- text_tokens(df$lyric, stemmer = "en") #lemmatize lyrics
  df <- data.frame(track_title = rep(df$track_title, sapply(df$lyric_stem, length)), word = unlist(df$lyric_stem)) #clean the dataframe
  df_sentiment <- merge(df, nrc, by = "word") ##inner join for sentiment counts
  df_sentiment <- as.data.frame(df_sentiment)
}

ui <- dashboardPage(skin = "black",
  dashboardHeader(title = "Sentimental Analysis"),
  dashboardSidebar(textInput("artist",             #INPUT: album + artist
                       "Artist", 
                       value = "Corbin"),
                   textInput("album",
                             "Album", 
                             value = "Mourn")
    
  ),
  dashboardBody(    
    tabsetPanel(type = "tabs",
                tabPanel(
                         "Album",
                         textOutput("Title"),    #title
                         imageOutput("Cover"),   #shows any cover album
                         uiOutput("Link"),       #URL link to the album page on genius.com 
                         "Tracklist", 
                         DT::dataTableOutput("mytable") #tracklist of the album
                         ),
                tabPanel("Sentiment Plot",       #plotly geombar sentimental analysis
                         plotlyOutput("affichage")
                         ),
                tabPanel("Wordcloud",           #wordcloud of the album
                         plotOutput("wcGenius")
                )
  )
)
)


server <- function(input, output) {
  
mydataset <- reactive({ get_album_sentiments(input$artist, input$album)}) #reactive dataset
 
  output$affichage <- renderPlotly({ 
    
    dataset <- as.data.frame(mydataset()) #turns "mydataset" into a dataframe
    
  #graph sentiments
  p <- ggplot(data =  dataset, aes(x = dataset$sentiment, y = 1, color = dataset$track_title)) + 
    geom_bar(stat = "identity", width = 0.675) + 
    labs(x = "Sentiment", y = "Sentiment Counts") +
    theme(plot.title = element_text(size=20, face="bold"), legend.position = "none") +
    scale_x_discrete(labels=c("anger" = "Anger","anticipation" = "Anticipation","disgust" = "Disgust","fear" = "Fear","joy" = "Joy","negative" = "Negative","positive" = "Positive","sadness" = "Sadness","surprise" = "Surprise","trust" = "Trust"))
  
  ggplotly(p) #turn the ggplot graph into a reactive plotly graph
  
  })
  
  output$mytable <- DT::renderDataTable({ #tracklist
    tracklist <- genius_tracklist(artist = input$artist, album = input$album)
    tracklist <- tracklist[, -c(2:3)] #take out unnecessary columns
    tracklist
  })
  
  output$Link <- renderUI({ #link to the web page of the albu on genius.com
    page <-gen_album_url(artist = input$artist, album = input$album)
    a("Check more about this Album on genius.com", href= page, target="_blank")
  })
  
  output$Cover <- renderImage({ #webscrap any album cover from genius.com
  page2 <- gen_album_url(artist = input$artist, album = input$album) #generates the url of the album page on genius.com
  webshot(page2 , #si pb essayer PhantomJS
          file = "screen2.png",
          selector = ".cover_art-image") 
  list(src = "screen2.png",
       contentType = 'image/png')
  
  })
  
  output$Title <- renderText({ c(input$album, " by ", input$artist) #reactive title
  })
  
  wordcloud_rep <- repeatable(wordcloud) #in order to make the wc reactive
  
  output$wcGenius <- renderPlot({ #display a wordcloud based on the chosen album
    
    dataset <- as.data.frame(mydataset()) #turns "mydataset" into a dataframe
    
    wordcloud_rep(dataset$word, 
                type ="text", 
                lang = "english", 
                colors=brewer.pal(8, "Dark2"), 
                max.words = 30)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)