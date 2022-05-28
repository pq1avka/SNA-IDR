@@ -0,0 +1,48 @@
library(tidyverse)
library(readr)
install.packages("twitteR")
library(twitteR)
library(rtweet)
library(jsonlite)
library(readr)
library(rlist)

appname <- "Information Diffusion in Network"
key <- api_key
secret <- api_secret_key
api_key <- "cOg6enCjhYcS5j2raWXlvUMlS"
api_secret_key <- "jHf71ZF31PT7p2OFjc7aS05EPTUA2rd0e9rjimi5jYYe3n885k"
access_token <- '1219650013502017543-igNaRLY3nRgqZelSxNyh95xNFWmR6k'
access_secret <- 'LhIKhfw4qPxrBUvVuIrhm7EmGFzTtjpUVgf4CxKbsi9sP'


twitter_token <- create_token(app = appname, consumer_key = api_key, 
                              consumer_secret = secret, access_token = access_token,
                              access_secret = access_secret )


###Key Terms Scraping in United States

##Data Manipulation Before Reaching the Keyterms
#All Data Mutated with Binary Values, 1 if misinformation 0 if not
conspiracy_theories <- read.csv(file.choose(), sep = "\t")
possible_values <- c("true","false","mostly true","half true","mostly false")
conspiracy_theories%>%filter(language == "en") -> conspiracy_theories_en
conspiracy_theories_en_possible_values <- conspiracy_theories_en%>%filter(label%in% possible_values)
conspiracy_theories_en_possible_values<-conspiracy_theories_en_possible_values%>%mutate(misinformation = ifelse(label != "true",1,0))

#Deriving the misinformation
conspiracy_theories_en_false <- conspiracy_theories_en_possible_values%>%filter(label != "true")
every_character <- list()
every_character_raw<- rbind(conspiracy_theories_en_false$claim)

#Seperate Every Word
every_character <- strsplit(every_character_raw, split = " ")
every_character_binded <- list.rbind(every_character)

every_character_binded <- as.factor(every_character_binded)

every_character_binded%>%summary()


