# sentimental-app
A Shiny application dedicated to sentimental analysis of music album lyrics.

## Based on Genius.com

This application is based on genius.com “the world’s biggest collection of song lyrics and musical knowledge” with more than 25 million songs, albums, artists, and annotations. Thanks to the genius package our app can access almost any album released on the internet. The drawback is that the API might be a bit slow from time to time.


## Sentimental analysis

The goal of this application was to analyze the lyrics of any album to figure out what kind of emotions they reveal. In order to do so we used the NRC lexicon: “These lexicons contain many English words and the words are assigned scores for positive/negative sentiment, and also possibly emotions like joy, anger, sadness, and so forth. The NRC lexicon categorizes words in a binary fashion (“yes” / “no”) into categories of positive, negative, anger, anticipation, disgust, fear, joy, sadness, surprise, and trust”. Lean more about it 


## Stemming approach

“In linguistic morphology and information retrieval, stemming is the process of reducing inflected (or sometimes derived) words to their word stem, base or root form—generally a written word form. The stem need not be identical to the morphological root of the word; it is usually sufficient that related words map to the same stem, even if this stem is not in itself a valid root.”
 – wikipedia  
We chose this approach to better fit the NRC lexicon and to have a more accurate match between sentiments and words. The drawback is that it slowers the process. 	

 
## UI part

I used the “shinydashboard” package to customize the UI aspect of the app with the dashboardPage formula. 
The two inputs are textInput: Artist and Album. If you don’t type the exact name of the artist and or album, it won’t work. I tried to implement some autocompletion with autocomplete_input but it didn’t work since I had no list with all the albums associated to their artist. One way to do so would have been to webscrap the whole genius.com website but I didn’t have the ressources to do so. 

The app is divided in 3 distinct panels: one for the album details (cover image, tracklist and hyperlink to the album webpage on genius.com), one for the sentimental analysis and one last panel containing a wordcloud of the most frequent words used in the chosen album. 

 
## Retrieve the cover pictures
In order to display any cover album, we generate the URL thanks to our inputs (Artist + album) and the gen_album_url from the Genius package. Then thanks to the webshot package, we pick up the picture using the CSS selector “.covert_art-image”. 
One drawback is that we often need to launch this command in R prior to run the app: ”webshot::install_phantomjs()” otherwise we get an error message in place of the cover.

 
## Sentiment plot

With the reactive sentiment count per track, we realized a geom_bar graph with the ggplot syntax before turning it into a plotly reactive graph.


## Wordcloud

To have a wordcloud in this app allows us to understand which are the most frequent words of the analyzed album. 


## Upgrade ideas

The app is a bit slow to generate both the sentiment plot and the wordcloud. What’s more the lack of autocompletion can be  frustrating for the user experience. Otherwise I had pretty good feedbacks from the people who wanted to test it. I think the main strength of this app is that the Genius API allows us to perform the analysis on millions of different albums. 
