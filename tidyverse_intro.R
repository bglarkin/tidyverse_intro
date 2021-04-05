#' ---
#' title: "Using the tidyverse!"
#' author: "Beau Larkin"
#' date: "2021-04-05"
#' output:
#'   github_document:
#'     toc: true
#'     toc_depth: 2
#'   pdf_document:
#'     df_print: tibble
#'     fig_caption: yes
#'     highlight: tango
#'     toc: true
#'     toc_depth: 2
#' ---
#'
#' # Description
#' 
#' * For University of Montana Course BIOB-595 - Art Woods, professor
#' * 2021-04-05 - Beau Larkin (guest instructor)
#' 
#' **Goals:**
#' 
#' * Show some features of the tidyverse
#' * Convince you that it's at least worth your time to learn more
#' * Give you some tools for further exploration
#' * != flexing huge skills
#' 
#' This session borrows heavily from [*R for Data Science*](https://r4ds.had.co.nz/index.html) (R4DS) 
#' by Wickham and Grolemund, 2017, O'Reilly, and from other sources as annotated in-text.
#' 
#' BTW What is this #' thing? It's useful. I'll show you at the end.
#' 
#' Let's get started!

# Package and library installation
packages_needed = c("tidyverse", "knitr", "nycflights13")
packages_installed = packages_needed %in% rownames(installed.packages())

if (any(! packages_installed))
    install.packages(packages_needed[! packages_installed])
for (i in 1:length(packages_needed)) {
    library(packages_needed[i], character.only = T)
}

#' # Engagement
#' What do you know about the tidyverse? Chat three words...
#' Do you use tidyverse packages and functions? Which packages?
#' 
#' ## Here's what I think:
#' 
#' * It's more than a collection of functions and fads (con sarn it, these new-fangled pipes!)
#' * A paradigm for data science, and it's here to stay
#' * Why tidyverse? It allows us to use intuitive, linear processes to get answers and results from data quickly
#'
#' ## A *paradigm*???
#' What do you need before creating graphics, applying models, and testing hypotheses? 
#' 
#' * ...
#' * The 80/20 rule...
#' 
#' # Tidy data 
#' 
#' * Chapter 12 in R4DS
#' * *Tidy Data* in the [Journal of Statistical Software, Wickham 2014](https://www.jstatsoft.org/article/view/v059i10). 
#' * You cannot pass into the tidyverse without tidy data! (whoa, that's biblical, but seriously
#' things don't work well in the tidyverse with messy data)
#' 
#' "Tidy data are tidy in the same way. Each messy dataset is messy in it's own way." - Wickham
#' 
#' ## Examples: messy data

#+ ex_1
ex_1 <- data.frame(
    plot_replicate = paste(rep(LETTERS[1:5], each = 4), rep(1:4, 5), sep = "_"), 
    date = rep("2016-06-12", 20),
    measurement_1 = rbinom(20, 50, 0.2)
)
ex_1[20, 2] <- "2016-06-12, measured after lunch"
kable(ex_1)
# View(ex_1)
# What is messy? Comment in chat but wait to submit...
#'
#' How would we produce a mean of measurement_1 in plots???
#+ aggregate_ex_1
aggregate(measurement_1 ~ plot_replicate, FUN = mean, data = ex_1) 
#' Guess it's "back to excel"

#+ ex_2
ex_2 <- data.frame(
    plot = rep(LETTERS[1:5], each = 8),
    replicate = rep(1:4, each = 2),
    parameter = rep(c("aphids_n", "height_cm"), 10),
    value = rep(c(700, 80), 10) + rbinom(40, 500, 0.4)
)
kable(ex_2)
# View(ex_2)
# What is messy? Comment in chat but wait to submit...

#' ## Tidy data rules:
#' There are three interrelated rules which make a dataset tidy:
#' 
#' 1. Each variable must have its own column.
#' 1. Each observation must have its own row.
#' 1. Each value must have its own cell.
#' 
#' So, remember the rules or just develop good habits that lead to intuition?
#' 
#' * Tidy or not? Not always binary...unfortunately. But like art, you know messy when you see it.
#' * Quickly recognize problems in data...
#' * Think ahead when planning to collect data...
#' 
#' ### At this point, *tibbles* often come up (see Chapter 10 in R4DS)
#' 
#' * Unavoidable in tidyverse, and mostly this is a good thing
#' * Occasional incompatibility issues, so be aware

#+ iris_tibble
# data frame
iris 
# tibble
(iris_t <- as_tibble(iris)) 
# sometimes you must convert
as.data.frame(iris_t)

#' # Pipes!! 
#' 
#' * What do you know already? Start with any vector `x`, and use a pipe to log transform `x` 
#' * Chapter 18 in R4DS
#' * [Pipes in R Tutorial For Beginners](https://www.datacamp.com/community/tutorials/pipe-r-tutorial)
#' 
#' How do we typically order data and functions, thinking of data as nouns and functions as verbs...

#+ pipes_intro
x <- c(0.109, 0.359, 0.63, 0.996, 0.515, 0.142, 0.017, 0.829, 0.907)
log(x) # this is verb, noun

#' The forward pipe aligns code with the order in which we think and speak
## # <- this is noun, verb

#' An annoying but useful example:
round(exp(mean(log(x))), 1) # "nested"
#' Closing parenthesis woes...
#' 
#' How would you say this in plain English? 
#' * "Round to 1 digit the exponentiated mean of the logarithm of x" <- AWFUL
#' 
#' ## With pipes:
x %>% log() %>% mean() %>% exp() %>% round(1)
#' Take x, log-transform it, average it, exponentiate it, and round it to 1 digit (**cheeky**)
#' 
#' Note: () not necessary but make the code easier to read by highlighting functions
#' 
#' Yeah, it's worth it to just spend 15 minutes dinking around with this kind of thing until you get it...
#' 
#' ## First position rule and the placeholder "."
#' Most functions take multiple arguments...
#+ first_position_rule
log(x, base = 2)
x %>% log(base = 2) %>% mean(na.rm = TRUE) %>% exp() %>% round(1)
x %>% log(., base = 2)
x %>% log(., base = 2) %>% mean(., na.rm = TRUE) %>% exp(.) %>% round(., 1) # Annoying, dot is implied

#' When noun isn't used in first position of a function, the "." is necessary
#+ aggregate_example, error=TRUE
# the trad way
aggregate(Sepal.Length ~ Species, FUN = mean, data = iris) 
# the naive but wrong pipe way
iris %>% aggregate(Sepal.Length ~ Species, FUN = mean) 
# the right pipe way
iris %>% aggregate(Sepal.Length ~ Species, FUN = mean, data = .) 

#' See package `magrittr` for other pipes that do fancy things, but the forward pipe is your workhorse
#' 
#' Whew! Let's pause for questions.
#' 
#' Chat a question if you have one. Chances are, someone else has the same question. 
#' 
#' # Verbs
#' The core of tidyverse usage, from package `dplyr`, verbs are what we do with our nouns (data), 
#' which are typically data frames (tibbles)
#' 
#' ## All verbs in the tidyverse:
#' 
#' 1. take a data frame as their first argument,
#' 1. identify variable names in subsequent arguments, without quotes, 
#' 1. and create a new data frame.
#' 
#' * Chapter 5 in R4DS
#' * Using `nycflights13::flights`. (Sorry not biology). This data frame contains all 336,776 flights that 
#' departed from New York City in 2013. Each row contains data from a single flight. 
#' The data comes from the US Bureau of Transportation 
#' Statistics, and is documented in `?flights`. Let's have a look:
#+ flights_data
flights
# The tibble view is handy, but still we cannot see all the variables

#' ## Verb: `glimpse()`
#' It's indispensable, as you'll see when we get to a complicated wrangle

#+ verb_glimpse
flights %>% glimpse()

#' ## Verb: `filter()`
#' 
#' * Acts on rows
#' 
#' ### Find United Airlines flights
#+ filter_intro
filter(flights, carrier == "UA")
# with forward pipe
flights %>% filter(., carrier == "UA")
flights %>% filter(carrier == "UA") # dot placeholder is implied

#' ### Find United Airlines and American Airlines flights
flights %>% filter(carrier == "UA" & carrier == "AA")
#' Wrong, trying to combine levels within one variable, use OR
flights %>% filter(carrier == "UA" | carrier == "AA")
#' Better: use value matching function `%in%`
flights %>% filter(carrier %in% c("UA", "AA"))

#' ### Find United Airlines or American Airlines flights longer than 1200 miles in July
#' Use AND to combine across variables
#+ filter_1
flights %>% filter(carrier %in% c("UA", "AA") & distance > 1200 & month == 7)
#+ filter_2, results=FALSE
flights %>% filter(carrier %in% c("UA", "AA"), distance > 1200, month == 7) # same-same & ,

#' ### On your own: how many flights on February 10 departed on time or earlier? 
#' Paste this into your script to get started:
packages_needed = c("tidyverse", "nycflights13")
packages_installed = packages_needed %in% rownames(installed.packages())

if (any(! packages_installed))
    install.packages(packages_needed[! packages_installed])
for (i in 1:length(packages_needed)) {
    library(packages_needed[i], character.only = T)
}

flights %>% glimpse()

#' Chat your answers to Art as quickly as you can...
# answer...

#' ## Verb: `select()`
#' 
#' * Acts on columns
#' 
flights %>% select(distance, air_time)

#' ## Verb: `mutate()`
#' 
#' * Acts on columns
#' * Creates new variables or replaces transformed, existing variables
#' 
flights %>% 
    select(distance, air_time) %>% 
    glimpse() %>% # in-line view with `glimpse()`
    mutate(speed_mph = distance / (air_time / 60))

#' ## Verbs: `group_by()` and `summarize()`
#' 
#' * Frequently used together
#' * Roughly like `tapply()` but much more flexible
#' * Act on rows grouped by variables, usually character or factor levels
#' * Prepares data frame for further transformation, produces results
#' 
#' ### Do different carriers fly at different speeds?
#+ group_by_summarize_intro
flights %>% 
    mutate(speed_mph = distance / (air_time / 60)) %>% 
    group_by(carrier) %>% 
    summarize(carrier_avg = mean(speed_mph))

#' What??? Oh yeah, NAs are contagious. For now, let's just nuke them:
flights %>% 
    glimpse() %>% 
    select(carrier, distance, air_time) %>% 
    glimpse() %>% 
    mutate(speed_mph = distance / (air_time / 60)) %>% 
    filter(!is.na(speed_mph)) %>% 
    glimpse() %>% # annoying, but makes the point
    group_by(carrier) %>% 
    summarize(carrier_avg = mean(speed_mph)) %>% 
    ungroup() %>% # you want this habit
    arrange(-carrier_avg) # yes another verb...

# how would you do this in base R? Obnoxious example:
#+ obnoxious, error=TRUE
flights_2 <- flights[, carrier]
# Ugh! Um...
flights_2 <- flights[, flights$carrier]
# stu##& R and %&^#ing #@%&&!
head(as.data.frame(flights))
flights_2 <- flights[which(complete.cases(flights)), c(10, 16, 15)]
flights_2$speed_mph <- flights_2$distance / (flights_2$air_time / 60)
flights_speed <- aggregate(speed_mph ~ carrier, FUN = mean, data = flights) # what???
flights_speed[order(desc(flights_speed$speed_mph)), ]

#' Of course it's doable, but it's harder to see what happened, and the intermediate objects always cause problems

#' ### Ok, what do the carrier codes stand for anyway?
#' From `?flights` we see that `airlines` is a data frame with the carrier names:
airlines

#' # Combine verbs for EDA (exploratory data analysis)
#' To motivate this part, let's make a guess and a follow-up explanation:
#' 
#' * We assume that departure delays are worse before winter holidays than in late January
#' * But do faster flying carriers make up lost time better? 
#'    * Let's limit this to departure delays under an hour. More than that and
#'    there is less to gain from hurrying. 

#+ flights_EDA_boxplot
flights %>% 
    filter(month %in% c(1, 12) & day == 20 & !is.na(dep_delay) & dep_delay <= 60) %>% 
    mutate(date = paste(year, month, day, sep = "-")) %>% 
    ggplot() + # You can wrangle straight into ggplot!!! Where is the placeholder? 
    geom_boxplot(aes(x = carrier, y = dep_delay)) +
    facet_wrap(vars(date))

#' Median departure delays are mostly below zero on 1-20 and above zero on 12-20

#+ flights_EDA_scatterplot_facets
flights %>%
    mutate( # sometimes breaking it out is more readable
        air_delay = arr_delay - dep_delay,
        speed_mph = distance / (air_time / 60),
        date      = paste(year, month, day, sep = "-")
    ) %>%
    filter(month %in% c(1, 12),
           day == 20, !is.na(air_delay),
           dep_delay <= 60) %>%
    # filter(!(carrier %in% c("AS", "F9", "FL", "HA", "VX", "YV"))) %>%
    ggplot(aes(x = speed_mph, y = air_delay, group = date)) +
    geom_smooth(aes(color = date),
                size   = 0,
                method = "lm",
                se     = TRUE) +
    geom_point(aes(color = date), size = 0.4) +
    geom_smooth(aes(color = date), method = "lm", se = FALSE) +
    facet_wrap(vars(carrier))

#' Are pilots pushing it before Christmas?

#' # Wrapping up
#' *R for Data Science*. Is this data mining or using data from planned experiments?
#' Thoughts and discussion. 
#' 
#' Questions and comments from you?
#' 
#' * If you are on GitHub, please comment, correct, or shred this script. [Link](https://github.com/bglarkin/tidyverse_intro) to repo.
#' * Or [download](https://mpgcloud.egnyte.com/dl/cguemdnod0) the R script
#' 
#' # Homework
#' 
#' * You will need to load the `tidyverse` library (after installing the package if necessary)
#' 
#' ## Transform a messy data frame into a tidy tibble
#' 
#' * Produce hw_1 using the code below. Use pipes and tidyverse functions to transform 
#' it into a tidy tibble. Hint = `?separate`
#+ hw_1
hw_1 <- data.frame(
    plot_replicate = paste(rep(LETTERS[1:5], each = 4), rep(1:4, 5), sep = "_"), 
    date = rep("2016-06-12", 20),
    measurement_1 = rbinom(20, 50, 0.2)
)

#' ## Are aphids more numerous on taller plants?
#' 
#' * Produce hw_2 using the code below. 
#' * Transform hw_2 into a tidy tibble using pipes and tidyverse functions. Hint = `?pivot_wider`
#' * Wrangle the data using tidyverse tools into ggplot to create scatterplots with 
#' linear trendlines superimposed.
#' * Put height_cm on the x axis, aphids_n on the y_axis, and facet on plot
#' * Hints: `?geom_point`, `?geom_smooth`, `?facet_wrap`
#+ hw_2
hw_2 <- data.frame(
    plot = rep(LETTERS[1:5], each = 8),
    replicate = rep(1:4, each = 2),
    parameter = rep(c("aphids_n", "height_cm"), 20),
    measurement = rep(c(700, 80), 20) + c(sort(rbinom(30, 500, 0.4)), rbinom(10, 500, 0.4))
)

#' ## Tidy vs. messy
#' 
#' * Explain why hw_3 (see below) is messy as it is
#' * Explain why hw_3 is tidy as it is
#' 
#' Hint: can you compare ants and aphids with `?geom_boxplot` and with a scatterplot (`?geom_point`) 
#' using the same configuration of hw_3, or is a transformation necessary to produce both of 
#' these plots? What does this suggest about independent observations and tidy data?
#+ hw_3
hw_3 <- data.frame(
    plot = rep(LETTERS[1:5], each = 8),
    replicate = rep(1:4, each = 2),
    insects = rep(c("aphids", "ants"), 20),
    count = rep(c(70, 20), 20) + rnorm(40, 0, 5) %>% round(., 0)
)

#' ## Bonus challenge
#' Use a [join](https://dplyr.tidyverse.org/reference/mutate-joins.html) function from `dplyr` to find out
#' how many different models of airplanes were flown out of New York by each airline
#'  in 2013. **Which carrier flew the largest number of airplane models?** 
#'  
#' * Hint: install/load `nycflights13` and then look at the `?planes` and `?flights` data 
#' frames.
