library(tidyverse)
library(tidytext)
library(stringr) # str_detect etc
library(lexicon) # profanity
library(qdapDictionaries) # language filtering
data(stop_words)

data(profanity_alvarez)
data(profanity_arr_bad)
data(profanity_banned)
data(profanity_racist)
data(profanity_zac_anger)

profanity_lexicon <- tibble(
  terms = c(profanity_alvarez, profanity_arr_bad, profanity_banned, profanity_racist, profanity_zac_anger)
) %>% filter(!str_detect(terms, " "))

basePath <- "~/DataScience/10_DataScienceCapstone/" # set to where your downloaded "final" folder is

if (!file.exists(paste0(basePath, "final"))) {
  download.file("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip", "Coursera-SwiftKey.zip")
  unzip("Coursera-SwiftKey.zip")
}

test_blogs <- tibble(line = read_lines(paste0(basePath, "final/en_US/en_US.blogs.txt")))
test_news <- tibble(line = read_lines(paste0(basePath, "final/en_US/en_US.news.txt")))
test_tweets <- tibble(line = read_lines(paste0(basePath, "final/en_US/en_US.twitter.txt")))

corpus <- bind_rows(
  test_blogs,
  test_news,
  test_tweets,
)

set.seed(123) # ensure same lines are sampled, for now
corpus <- corpus %>% sample_n(n()/20)
rm(test_blogs, test_news, test_tweets)

corpus <- bind_rows(
  corpus %>% unnest_tokens(ngram_text, line, token = "ngrams", n = 3),
  corpus %>% unnest_tokens(ngram_text, line, token = "ngrams", n = 2)
)
corpus <- corpus %>% filter(!is.na(ngram_text))

corpus <- corpus %>% filter(!(grepl("\\d", ngram_text))) # remove rows containing digits
corpus <- corpus %>% filter(!(grepl("\\.", ngram_text))) # remove rows containing full stops
corpus <- corpus %>% extract(ngram_text, into = c('predictor', 'predicted'), '(.*)\\s+([^ ]+)$') # pretty fast
corpus <- corpus %>% filter(!predicted %in% profanity_lexicon$terms) # remove rows where any predicted value would be a profane term (profanity still allowed in predictor)
corpus <- corpus %>% filter(predicted %in% GradyAugmented) # remove rows where predicted value not in dictionary
corpus <- corpus %>% filter(!predicted %in% stop_words$word) # remove rows where predicted word is a stop word - IS THIS GOOD
corpus <- corpus %>% group_by(predictor) %>% count(predicted, sort = TRUE) %>% slice_head(n = 3) %>% select(-n) # slow
corpus <- corpus %>% mutate(id = row_number())  %>% pivot_wider(names_from = c(id), values_from = c(predicted), names_prefix = "predicted")

write.csv(corpus, file = gzfile("corpus.csv.gz"), row.names = FALSE)

