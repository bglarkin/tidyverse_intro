## Pipes, dplyr, magrittr, and tidyverse lessons
## Starting 6 September 2018
## Beau Larkin


#### ---------------- Packages and Libraries ---------------- ####


wants <-
    c("magrittr", "babynames", "dplyr", "formatR") # comma delimited vector of package names
has   <- wants %in% rownames(installed.packages())
if (any(!has))
    install.packages(wants[!has])
for (i in 1:length(wants)) {
    library(wants[i], character.only = T)
}


#### ---------------- Piping ---------------- ####


# From https://www.datacamp.com/community/tutorials/pipe-r-tutorial

# Simple function with variables: the hard way:
# Initialize `x`
x <-
    c(0.109, 0.359, 0.63, 0.996, 0.515, 0.142, 0.017, 0.829, 0.907)
# Compute the logarithm of `x`, return suitably lagged and iterated differences,
# compute the exponential function and round the result
round(exp(diff(log(x))), 1)

# With pipes: the easy way
# Note: () not necessary but make the code look cleaner
x %>% log() %>% diff() %>% exp() %>% round(1)
x %>% log %>% diff %>% exp %>% round(1)

# Passing data through filtering and summary steps:
iris %>% subset(Sepal.Length > 5) %>% aggregate(. ~ Species, ., mean)
# Note that the (.) in aggregate() is a placeholder for data=, an argument that is necessary in aggregate()

# Another nested function example
# Reads left to right, simpler than nesting. Note that filter() is from dplyr
# Does not need a placeholder because results are piped to the first argument of the next function
babynames %>% filter(sex == "M", name == "Taylor") %>% select(n) %>% sum()

# Placeholders needed when data are piped to a subsequent argument in the function
# note that 'zfp is my expander widget for "forward pipe"
pi %>% round(6) # No placeholder; pi passes to the first argument
6 %>% round(pi, digits = .) # Placeholder; 6 passes to second argument
6 %>% round(pi, .) # Shorter

# First-argument rule also applies in nested functions
# Initialize a matrix `ma`
ma <- matrix(1:12, 3, 4)
ma
# Return the maximum of the values inputted
max(ma, nrow(ma), ncol(ma))
# Return the maximum of the values inputted
ma %>% max(nrow(.), ncol(.)) # Does not work as "ma" is still treated as first argument to max()
ma %>% {
    max(nrow(.), ncol(.))
} # Braces overrule the first-argument rule

# Using pipes for functions
# Unary function
f <- . %>% cos %>% sin
f
f(45)

# Compound assignment pipe operations. Assigns results back to variable!
# Normally, you'd have to assign a column to the result of some calculation:
iris2 = iris
iris2$Sepal.Length
iris2$Sepal.Length = f(iris2$Sepal.Length)
iris2$Sepal.Length
# Compound pipe does the reverse assignment in one step
# Compound pipe must be first in line. Anything downstream gets reassigned to the first item in the chain
iris2$Sepal.Width %<>% f()
iris2$Sepal.Width # text expander widget for this is 'zcp

# Tee operator
# Returns the left side of the function; good for functions that don't actually return a result
# plot() and print() are examples
set.seed(123)
mat = rnorm(200) # Done without pipes here to play with behavior of pipes below
mat %>% matrix(ncol = 2) %>% plot() %>% colSums() # does not pass useful data to colSums()
mat %>% matrix(ncol = 2) %T>% plot() %>% colSums() # Tee takes matrix and passes it to, and over, plot() so that colSums are computed
mat %>% matrix(ncol = 2) %>% colSums() %>% plot() # Can't fix it by changing the order because plot() gets the wrong information


# Exposition operator: useful for dataframes
# Also functions like cor() and plot() that don't have data= arguments
# This makes it hard to pass data to them through the pipe
iris %>% subset(Sepal.Length > mean(Sepal.Length)) %>% cor(Sepal.Length, Sepal.Width)
# Doesn't work because the dataframe is not passed as useable arguments to cor()
iris %>% subset(Sepal.Length > mean(Sepal.Length)) %$% cor(Sepal.Length, Sepal.Width)
iris %>% subset(Sepal.Length > mean(Sepal.Length)) %$% plot(Sepal.Length, Sepal.Width)
plot(subset(iris, Sepal.Length > mean(Sepal.Length))[, 1:2]) # A traditional approach. It is more opaque for sure



tidy_eval(paste(getwd(), "/PipesDplyrTidyverse_script.R", sep = ""),
          width.cutoff = 60)


