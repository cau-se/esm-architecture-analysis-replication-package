# Parameter

options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

experiment_name <- args[1]

dynamic_distinct_function_degree <- read.csv(sprintf("combined-result/%s-dynamic-distinct-function-degree.csv", experiment_name), header=FALSE, sep=";")
dynamic_distinct_module_degree   <- read.csv(sprintf("combined-result/%s-dynamic-distinct-module-degree.csv", experiment_name), header=FALSE, sep=";")
dynamic_extra_edges              <- read.csv(sprintf("combined-result/%s-dynamic-extra-edges.csv", experiment_name), header=FALSE, sep=";")
dynamic_function_calls           <- read.csv(sprintf("combined-result/%s-dynamic-function-calls.csv", experiment_name), header=FALSE, sep=";")

static_distinct_function_degree  <- read.csv(sprintf("combined-result/%s-static-distinct-function-degree.csv", experiment_name), header=FALSE, sep=";")
static_distinct_module_degree    <- read.csv(sprintf("combined-result/%s-static-distinct-module-degree.csv", experiment_name), header=FALSE, sep=";")
static_extra_edges               <- read.csv(sprintf("combined-result/%s-static-extra-edges.csv", experiment_name), header=FALSE, sep=";")

rowmedian <- function(data) {
        medianValue <- median(data)
        allMatches <- which(!is.na(match(data, medianValue)))
        allMatches[1]
}

distinct_function <- function(label, data) {
        print(label)
        row <- which.max(data[,3])
        v <- data[row,]
        print(sprintf("Max in %s %s %d",v[,1],v[,2],v[,3]))
        row <- which.max(data[,4])
        v <- data[row,]
        print(sprintf("Max out %s %s %d",v[,1],v[,2],v[,4]))

        row <- which.min(data[,3])
        v <- data[row,]
        print(sprintf("Min in %s %s %d",v[,1],v[,2],v[,3]))
        row <- which.min(data[,4])
        v <- data[row,]
        print(sprintf("Min out %s %s %d",v[,1],v[,2],v[,4]))

        row <- rowmedian(data[,3])
        v <- data[row,]
        print(sprintf("Median in %s %s %d",v[,1],v[,2],v[,3]))
        row <- rowmedian(data[,4])
        v <- data[row,]
        print(sprintf("Median out %s %s %d",v[,1],v[,2],v[,4]))
        print("")
}

distinct_module <- function(label, data) {
        print(label)
        row <- which.max(data[,2])
        v <- data[row,]
        print(sprintf("Max in %s %d",v[,1],v[,2]))
        row <- which.max(data[,3])
        v <- data[row,]
        print(sprintf("Max out %s %d",v[,1],v[,3]))

        row <- which.min(data[,2])
        v <- data[row,]
        print(sprintf("Min in %s %d",v[,1],v[,2]))
        row <- which.min(data[,3])
        v <- data[row,]
        print(sprintf("Min out %s %d",v[,1],v[,3]))

        row <- rowmedian(data[,2])
        v <- data[row,]
        print(sprintf("Median in %s %d",v[,1],v[,2]))
        row <- rowmedian(data[,3])
        v <- data[row,]
        print(sprintf("Median out %s %d",v[,1],v[,3]))
        print("")
}

dynamic_function <- function(label, data) {
        print(label)
        row <- which.max(data[,5])
        v <- data[row,]
        print(sprintf("Max from %s %s -> %s %s  %s", v[1], v[2], v[3], v[4], v[5]))
        row <- which.min(data[,5])
        v <- data[row,]
        print(sprintf("Min from %s %s -> %s %s  %s", v[1], v[2], v[3], v[4], v[5]))
        row <- rowmedian(data[,5])
        v <- data[row,]
        print(sprintf("Median from %s %s -> %s %s  %s", v[1], v[2], v[3], v[4], v[5]))
}

# process data

print("-------------------------------")
print(experiment_name)
print("-------------------------------")

dynamic_function("Dynamic function calls", dynamic_function_calls)

distinct_function("Dynamic distinct function calls", dynamic_distinct_function_degree)
distinct_module("Dynamic distinct module calls", dynamic_distinct_module_degree)


distinct_function("Static distinct function calls", static_distinct_function_degree)
distinct_module("Static distinct module calls", static_distinct_module_degree)

print("")
