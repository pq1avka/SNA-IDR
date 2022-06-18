library(tidyverse)
library(igraph)
library(ggraph)
library(graphlayouts)



read.csv(file.choose()) -> tweets

tweets%>%select(screen_name,retweet_screen_name)%>%
  separate_rows(retweet_screen_name, sep = " ")%>%
  filter(retweet_screen_name != "") -> tweets_necessary_columns


nodes <- data.frame(name = unique(c(tweets_necessary_columns$screen_name, 
                                     tweets_necessary_columns$retweet_screen_name)), stringsAsFactors = FALSE)





preliminary <- graph_from_data_frame(tweets_necessary_columns, directed = FALSE, vertices = nodes)



V(preliminary)$clu <-  as.character(membership(cluster_louvain(preliminary)))
V(preliminary)$size <-  degree(preliminary)


for (i in 1:503) {
  if("drfahrettinkoca" %in% V(decompose(preliminary)[[i]])$name){
    print(i)
  } else{
  }
}

elements <- decompose(preliminary)[[1]]
for (i in 1:503) {
  if(diameter(decompose(preliminary)[[i]])>= 5){
  elements <-  decompose(preliminary)[[i]] + elements
  } else{
  }
}
elements <- elements + decompose(preliminary)[[164]]




V(elements)$clu <-  as.character(membership(cluster_louvain(elements)))
V(elements)$size <-  0.0000001
V(elements)$weights <- 0.01


ggraph(elements, layout = 'stress') + 
  geom_node_point(aes(size = degree(elements), color = clu))+
  geom_node_text(aes(label = NA)) + 
  geom_edge_link(alpha = 0.1, color = "grey66")+ 
  theme_graph(foreground = 'steelblue', fg_text_colour = 'white')


