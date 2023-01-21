library(readr)
library(tidyverse)

# Wczytanie słownika języka polskiego z odmianami ze strony: https://sjp.pl/sl/odmiany/
# dłuższa wersja// slownik <-read.delim("odm.txt", sep="\t", header = FALSE, encoding="UTF-8")

slownik <- read_tsv("odm.txt", col_names = "wyrazy")

#stworzenie ramki danych 
slownik_df <- as.data.frame(slownik)

# stworzenie macierzy wyrazów poprzez rozdzielenie wyrazów

slownik_matrix<- str_split(slownik_df[1:nrow(slownik_df),], ", ", simplify=TRUE)

# zamiana dużych liter na małe
SL<-tolower(slownik_matrix)

# Dalej to do stabilnej ramki danych z powrotem, ponieważ w macierzy nie pokazuje indeksów wiersza jedynie miejsce w macierzy
SL <- as.data.frame(SL)

# zamiana pustych miejsc na "eNAejki"
SL[SL==""]<-NA

