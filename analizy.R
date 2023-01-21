library("arules")
library("arulesViz")
library("dplyr")

#pobranie wyników z każdego dnia z bazy
dane<-dbGetQuery(con, "SELECT * FROM baza_slow")

# zbdanie liczby wyrazów 
dane %>%
  group_by(slowo)%>%
  summarise(liczba = sum(liczba))%>%
  arrange(desc(liczba))%>%
  filter(liczba >10)

# Reguły asocjacyjne

slowo<- split(dane$slowo, f=list(dane$data,dane$portal,dane$nr))

names(slowo) <- paste("S", c(1:length(slowo)), sep = "")

trans <- as(slowo, "transactions")

length(slowo)

dim(trans)
summary(trans)
image(trans)

itemFrequencyPlot(trans, topN=20,  cex.names=1)

rules <- apriori(trans, 
                 parameter = list(supp=0.002, conf=0.01, 
                                  maxlen=5, 
                                  target= "rules"))

summary(rules)

inspect(rules)

rhs <- apriori(trans, 
               parameter = list(supp=0.001, conf=0.50, 
                                maxlen=5, 
                                minlen=2),
               appearance = list(default="lhs", rhs="Polska"))
summary(rhs)

inspect(rhs)