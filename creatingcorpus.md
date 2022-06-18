---
title: "Creating a Corpus and Maske Tweet Analysis"
author: "Onur Tuncay Bal"
date: "6/2/2022"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Abstract

In this part of the project, for finding who spreads the conspiracy theories at the most amount we have to create, analyze and search with a created corpus. This corpus should be gathered with the words from tweets that contains misinformation. Thus we need to search for the general database of collected misinformation. This can be done via multiple ways but searching with an already existing database created by World Fact Checking Organization is extremely useful. Here is the github link to the database.

https://github.com/utahnlp/x-fact

After manipulating data we will create a corpus that comes from misinformation network of Republic of Turkey. 

QUICK NOTICE: Twitter API access is pre-defined. For running the code completely you need a twitter API access. 


```{r, echo = FALSE}
# Preamble
library(tidyverse)
library(tidytext)
library(rjson)
```

# Creating the Corpus

## Examining of the Database of utahnlp/x-fact

In the beginning I will be focusing on their  data. It can be shown as below.

```{r, echo = TRUE}
all_checked_information <- data.table::fread("train.all.tsv") 
```
Let's go over and filter for the language Turkish


```{r, echo = TRUE}
all_checked_information%>%filter(language == "tr") -> all_checked_information_tr
#Controlling the Dataset
print(head(all_checked_information_tr,10))

```

Now we have to search any claim that is not true, therefore we will include, mostly true, mostly false, completely false etc. Furthermore, after filtering we will drop the columns unnecessary and will just work on the claim column.

```{r, echo = TRUE}
all_checked_information_tr%>%filter(label != "true") -> all_checked_misinformation_tr
all_checked_misinformation_tr_selected <-  all_checked_misinformation_tr%>%select(claim)
##Controlling
head(all_checked_misinformation_tr_selected,20)
all_checked_misinformation_tr_selected <- as_tibble(all_checked_misinformation_tr_selected)
## Filtered Well. Lets Continue... We will split every word for creating a common usage corpus.
all_checked_misinformation_tr_selected_tokened <- all_checked_misinformation_tr_selected%>%unnest_tokens(words,claim)
acmtst_filtered <- all_checked_misinformation_tr_selected_tokened%>%filter(!words%in%stopwords::stopwords(language = "tr", source = "stopwords-iso"))
acmtst_filtered%>%count()
```

## Text Mining with Tidy Text
```{r, echo = TRUE}


tidy_prep <- as_tibble(all_checked_misinformation_tr_selected)
tidy_token <- tidy_prep%>%unnest_tokens(word,claim)

as.data.frame(tidy_token%>%count(word, sort = TRUE)) -> freq_table



```


## Another Approach

Let's create a corpus like  database with another methodology. In the file above we have scraped all necessary content, nearly 400 from a Turkish fact checking website named "Doğruluk Payı". These topics are selected from their section of Health. We have scraped the css "-user.content". Which denotes to the articles they have wrote. 

```{r, echo = TRUE}

all_articles_raw <- "outputfile.json"
all_articles <- fromJSON(file = all_articles_raw)
```
As we can see now all_articles element contains a list with three object within every object. We need to derive the user content out of every object so we will create a for loop for this.

```{r, echo = TRUE}
all_user_content <- as.data.frame(matrix(nrow = length(all_articles), ncol = 1))

for(i in 1:length(all_articles)){
  all_user_content[i,1] <- all_articles[[i]]$usercontent
}
```

Let's work with tidytext from now on for text mining and finding the common words.
```{r, echo = TRUE}

all_user_content <-as_tibble(all_user_content)
all_words_unnested <-  all_user_content%>%unnest_tokens(words,V1) #15.621 Row Words.

all_words_unnested%>%count(words)%>%arrange(desc(n))

all_words_unnested_filteredbystopwords<- all_words_unnested%>%filter(!words%in%stopwords::stopwords(language = "tr", source = "stopwords-iso"))
all_words_unnested_filteredbystopwords%>%count(words)%>%arrange(desc(n))
```


And founding final common place,

```{r, echo = TRUE}
all_words_unnested_filteredbystopwords%>%count(words)%>%arrange(desc(n)) -> final_word_list
```

Let's go over and find most common health related topics that used for transforming information and lets find the place of our mis-mal-false information spreaders.



```{r, echo = TRUE}
final_word_list%>%filter(n >= 10) -> final_word_list
```
We can see that following words are repetitevly used by fact checking organization about health issues. So we have decided to search these words and see the effect of related agents.


## a Reasoning for The Methodology
In the beginning we should state that our aim is to find the impact of the widely known conspiracy theory spreaders and their impact on information diffusion over the network. This is rather important to understand how false,mis,mal- information spreads over the social networks such as Twitter and in the case of Turkey it is rather new. Our common word filtering will reveal the most frequent debates. For example, misinformation spreader can talk about variety of subjects, nonetheless our main aim is to find most relevant topics, related to health. We could have created a corpus like object for variety of tweets and then filter the common words but words like "Bill Gates" may have had escaped on a scale like this. We know that, Bill Gates in our corpus is related to health since we derived the words from health related claims. Thus, now it gains its meaning in a context. 


Final Word List;

```{r, echo = TRUE}
final_words_health <- c("covid","sağlık","aşı","tıp","salgın","pfizer","koronavirüs","biontech","hastalık","kanser","gates")
```

## Maranki's Tweets Frequent Word Analysis
```{r, echo = TRUE}
library(rtweet)
get_timeline("@maranki", n = 1000, parse = TRUE)-> maranki_timeline

maranki_timeline%>%select(text) -> maranki_tweets
maranki_tweets <- as.tibble(maranki_tweets)

maranki_tweets%>%unnest_tokens(word,text) -> maranki_tweets

maranki_tweets%>%count(word)%>%arrange(desc(n)) -> maranki_tweets_unnested_arranged
```
Let's filter it with Turkish Stop Words,

```{r, echo = TRUE}
maranki_tweets_unnested_arranged%>%filter(!word%in%stopwords::stopwords(language = "tr",source = "stopwords-iso")) -> maranki_tweets_unnested_arranged_filtered
maranki_tweets_unnested_arranged_filtered[1:40,]->maranki_tweets_unnested_arranged_filtered_top 
maranki_tweets_unnested_arranged_filtered_top%>%filter(!word %in% c("t.co","mi","maranki","1","vs","2","15","içinde","dersiniz","https")) -> maranki_filtered_tweets_unnested_arranged_filtered_top


##Graph
maranki_filtered_tweets_unnested_arranged_filtered_top%>%ggplot(mapping = aes(x = reorder(word,n), y = n*100/sum(n))) + geom_col(fill = "sienna") + coord_flip() + theme_minimal() + xlab("Repeated Words") + ylab("Words by %") + ggtitle(label = "User @maranki (Ahmet Maranki) Frequent Word Analysis")
```
## Abdurrahman Dilipak's Analysis
```{r, echo = TRUE}
get_timeline("@aDilipak", n = 1000, parse = TRUE) -> aDilipak_timeline

```
```{r, echo = TRUE}
##Filtering tweets, including retweets
aDilipak_timeline%>%select(text) -> aDilipak_tweets
aDilipak_tweets%>%unnest_tokens(word,text) -> aDilipak_tweets_unnested

aDilipak_tweets_unnested%>%count(word)%>%arrange(desc(n)) -> aDilipak_tweets_unnested_arranged
##Stop word filtering
aDilipak_tweets_unnested_arranged%>%filter(!word %in%stopwords::stopwords(language = "tr", source = "stopwords-iso")) -> aDilipak_tweets_unnested_arranged_filtered

aDilipak_tweets_unnested_arranged_filtered_top <- aDilipak_tweets_unnested_arranged_filtered%>%filter(!word%in% c("https","t.co","dilipak","abdurrahman","adilipak","mi","1","2","15","3","4","aracılığıyla"))
aDilipak_tweets_unnested_arranged_filtered_top <-  aDilipak_tweets_unnested_arranged_filtered_top[1:40,]

ggplot(data = aDilipak_tweets_unnested_arranged_filtered_top, mapping = aes(x = reorder(word,n), y = n*100/sum(n))) + geom_col(fill = "khaki4") + coord_flip() + xlab("Words") + ylab("Frequency by %") + ggtitle(label = "User @aDilipak (Abdurrahman Dilipak) Frequent Word Analysis") + theme_minimal()
```



## 5gvirusnewss Word Analysis

```{r, echo = TRUE}
fivegvirusnewss_timeline <- get_timeline("@5gvirusnewss", n = 1000, parse = TRUE)
fivegvirusnewss_timeline%>%select(text)%>%unnest_tokens(word,text) -> fivegvirusnewss_timeline_unnested
fivegvirusnewss_timeline_unnested%>%filter(!word %in% stopwords::stopwords(language = "tr", source = "stopwords-iso"))%>%filter(!word %in% c("https","t.co","1","3","2","19")) %>%count(word)%>%arrange(desc(n)) -> fivegvirusnewss_timeline_unnested_filtered


fivegvirusnewss_timeline_unnested_filtered[1:40,] -> fivegvirusnewss_timeline_unnested_filtered
fivegvirusnewss_timeline_unnested_filtered%>%ggplot(mapping = aes(x = reorder(word,n), y = n*100/sum(n))) + geom_col(fill = "lightskyblue4") + coord_flip() + ylab("Words by %") + xlab("Words") + ggtitle(label = "User @5gvirusnewss Frequent Word Analysis")

```

## Erkan Trukten Tweet Analysis

```{r, echo = TRUE}
Etrukten_timeline <- get_timeline("@ErkanTrukten", n = 1000, parse = TRUE)
Etrukten_timeline%>%select(text)%>%unnest_tokens(word,text)%>%filter(!word %in%stopwords::stopwords(language = "tr", source = "stopwords-iso"))%>%count(word)%>%arrange(desc(n)) -> Eturkten_timeline_arranged

Eturkten_timeline_arranged <- Eturkten_timeline_arranged[1:50,]%>%filter(!word %in% c("https","t.co","4","mi","erkantrukten","19","a","15.00","erkan","dedi","diyor"))
Eturkten_timeline_arranged%>%ggplot(mapping = aes(x = reorder(word,n), y = n * 100/sum(n))) + geom_col(fill = "orange3") + coord_flip() + ggtitle("User @ErkanTrukten (Erkan Trükten) Frequent Word Analysis") + xlab("Words") + ylab("Words by %") + theme_minimal()
```

## Finding Common Conspiracy Terms

Since we know that, conspiracy theories generally include common terms of "big picture" or "sinister plans" of an ezoteric structure. We have decided to find these common words used by these users. We have used the following approach.
```{r}
aDilipak_tweets_unnested_arranged -> common_word_adilipak
Eturkten_timeline_arranged -> common_word_eturkten
fivegvirusnewss_timeline_unnested_filtered -> common_word_fivegvirusnewss
maranki_filtered_tweets_unnested_arranged_filtered_top -> common_word_maranki

##Stopwords application

common_word_adilipak%>%filter(!word %in% stopwords::stopwords(language = "tr", source = "stopwords-iso")) -> common_word_adilipak

common_word_eturkten%>%filter(!word %in% stopwords::stopwords(language = "tr", source = "stopwords-iso")) -> common_word_eturkten

common_word_fivegvirusnewss%>%filter(!word %in% stopwords::stopwords(language = "tr", source = "stopwords-iso")) -> common_word_fivegvirusnewss

common_word_maranki%>%filter(!word %in% stopwords::stopwords(language = "tr", source = "stopwords-iso")) -> common_word_maranki

## Removing URLS and t.co
common_word_adilipak%>%filter(!word%in%c("https","t.co")) -> common_word_adilipak
```
Final versions of the common words as a table can be found as below.


```{r}
common_words <- as.data.frame(matrix(nrow = 40, ncol = 4))
common_words[,1] <- common_word_adilipak$word[1:40]
common_words[,2] <-  common_word_eturkten$word[1:40]
common_words[,3] <-  common_word_fivegvirusnewss$word[1:40]
common_words[,4] <-  common_word_maranki$word[1:40]
colnames(common_words) <-  c("aDilipak","Eturkten","fivegvirusnews","maranki")
head(common_words, 20)
```

Finally we compared them within each other and analyzed same words and created the following table,

```{r}
repeating_words <- list()

```

After here we will apply SNA approach to these words by scraping data from twitter.





