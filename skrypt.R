library(rvest)
library(stringi)
library(dplyr)
library(stopwords)
library(DBI)
library(RMariaDB)

source("slownik.R")

#Funkcja ujednolicająca słowa
  fun <- function(x)  {
    indeks <- as.data.frame(which(SL == x, arr.ind=TRUE))
    
    ind <- subset(indeks,col==min(col))
    paste(slownik_matrix[ind[1,1],1])
    
  }
  
## połączenie z lokalną bazą gdzie zostaną wyeksportowane otrzymane dane
  con <- dbConnect(RMariaDB::MariaDB(),
                   dbname = "trudneslowa",
                   username = "root",
                   password = "",
                   host= "localhost",
                   port = 3306) 
  
## zdefiniowanie nie potrzebnych znaków i wyrazów
  wycinka <- c("[","]","-",":","\".",".",",","\" ",'"','.',"?","!")
  znaki <- c("\\?","\\!","\\,","\\.","\\n",'„','”','\"')
  stopwordy<- stopwords::stopwords("pl", source = "stopwords-iso")

#--------------------------------------  
## haczyki za co złapać tytuł na danej stronie + przykładowe strony
tvph<- c(".news__title", ".large-box__description--title", ".large-box__description--title",".news__title three-boxes__title",".information__text",".title")
tvnh<- c(".article-title",".report-article__ellipsis")
polsath <- c(".news__title")
o2h <- c("h3")
zeth <- c(".box__item__title")

## lista stron z adresami URL 
lista<-list(c("o2","https://o2.pl", o2h),
     c("tvpinfo","https://tvp.info", tvph),
     c("polsat","https://polsatnews.pl", polsath),
     c("tvn24","https://tvn24.pl", tvnh),
     c("radiozet","https://radiozet.pl", zeth))
##--------------------------------------------------

# Odpalenie poniższego for'a spowoduje pobranie wyrazów z tytułów, ujednolici 
# i wyeksportuje je bazy z odpowiednimi wartościami
for(h in 1:length(lista))
{
# wczytanie strony  
strona <- read_html(lista[[h]][2])

# jeden tytuł jeden rekord
a<- as.character()
  for(i in lista[[h]][3:length(lista[[h]])])
  {
  a<-c(a,a<-strona %>%
    html_nodes(i) %>%
    html_text()%>%
    trimws())
  }
# usunięcie niepotrzebnych znaków
  for(z in znaki){
    a<-as.vector(gsub(z, "", a))
  }
  for(w in wycinka){
  a<-as.vector(stri_replace(a, "", fixed=w))
  }

# podział zdań na pojedyncze wyrazy
#twarda spacja \\W
b<- as.vector(strsplit(a,split ="\\W"))
b1<- unlist(b)
b1<- tolower(b1)
b1 <- b1[!(b1 %in% stopwordy)]
b1 <- b1[!(b1 %in% "")]

# funkcja do tworzenia id zdania dla wyrazu
db<- data.frame(wyraz = NA, nr=NA)
for(x in 1:length(b))
{
  for(y in 1:length(b[[x]]))
  {
   db<-rbind(db,c(b[[x]][y],x))
  }
}
db<- db[2:length(db$wyraz),]
db$wyraz <- tolower(db$wyraz)
db <- subset(db, !wyraz %in% stopwordy)
db <- subset(db, !wyraz %in% "")

#--------------------------------------------------
# zastosowanie funkcji ujednolicającej wyrazy
  c<- c()
  for(z in b1){
    c <- c(c,fun(z))
  }

db$slowo <- c
db$liczba <- 1 
db$portal <- lista[[h]][1]
db$data <- Sys.Date()

# w przypadku braku możliwości ujednolicenia przepisanie wyrazu 
# i dodanie informacji czy ujednolicenie się udało
db$zmiana <- ifelse(db$slowo =="NA",FALSE,TRUE)
db$slowo <- ifelse(db$slowo =="NA",db$wyraz,db$slowo)


#wysłanie wyników do bazy
dbWriteTable(con, 
             name = "baza_slow", 
             value = db,append=TRUE)
}