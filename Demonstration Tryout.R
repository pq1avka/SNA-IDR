


#Libraries
library(tidyverse)
library(readr)
library(stopwords)
library(twitteR)
library(rtweet)
library(jsonlite)
library(readr)
library(rlist)
library(purrr)
library(tidytext)
library(igraph)

sessionInfo()


#Token Configuration
appname <- "Information Diffusion in Network"
key <- api_key
secret <- api_secret_key
api_key <- "cOg6enCjhYcS5j2raWXlvUMlS"
api_secret_key <- -
access_token <- -
access_secret <- -


twitter_token <- create_token(app = appname, consumer_key = api_key, 
                              consumer_secret = secret, access_token = access_token,
                              access_secret = access_secret )





get_timeline("@aDilipak", n = 10000) -> adilipak_all



#Sort by retweet count
adilipak_all%>%arrange(desc(retweet_count)) -> adilipak_all_arranged_by_retweet
adilipak_all_arranged_by_retweet <-  adilipak_all_arranged_by_retweet%>%filter(is_retweet == "FALSE")
head(adilipak_all_arranged_by_retweet,20)



hoax_covid_adilipak <- search_fullarchive("Covid yalanına inandınız, yeni korku pandemisi", n = 2000, env_name = "allaccess")





hoax_covid_adilipak%>%select(screen_name,retweet_screen_name) -> edges_and_nodes

covid_hoax_network <- graph_from_edgelist(el = as.matrix(edges_and_nodes), directed = TRUE)

plot(covid_hoax_network, edge.arrow.size = 0.2, edge.curved = 0.6, vertex.color = "khaki4",
     vertex.size = 0.2, 
     vertex.label = NA,edge.color = "cornsilk3")



g <- graph_from_data_frame(edges_and_nodes,directed = TRUE)
plot(g, edge.arrow.size = 0.2, edge.curved = 0.6, vertex.color= "indianred4", vertex.size = degree(g)/200,edge.color = "cornsilk3", vertex.label = ifelse(degree(g)>= 50, "@aDilipak",NA))


