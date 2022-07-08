# Parameter

#options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

experiment_name <- args[1]
location <- args[2]
type <- args[3]

dynamic_distinct_function_degree <- read.csv(sprintf("%s/%s-%s-dynamic-distinct-function-degree.csv", location, experiment_name, type), header=FALSE, sep=";")
dynamic_distinct_module_degree   <- read.csv(sprintf("%s/%s-%s-dynamic-distinct-module-degree.csv", location, experiment_name, type), header=FALSE, sep=";")
dynamic_extra_edges              <- read.csv(sprintf("%s/%s-%s-dynamic-extra-edges.csv", location, experiment_name, type), header=FALSE, sep=";")
dynamic_function_calls           <- read.csv(sprintf("%s/%s-%s-dynamic-function-calls.csv", location, experiment_name, type), header=FALSE, sep=";")

if ( location == "combined-result" ) {
        static_distinct_function_degree  <- read.csv(sprintf("combined-result/%s-static-distinct-function-degree.csv", experiment_name), header=FALSE, sep=";")
        static_distinct_module_degree    <- read.csv(sprintf("combined-result/%s-static-distinct-module-degree.csv", experiment_name), header=FALSE, sep=";")
        static_extra_edges               <- read.csv(sprintf("combined-result/%s-static-extra-edges.csv", experiment_name), header=FALSE, sep=";")
}

rowmedian <- function(data) {
        medianValue <- median(data)
        allMatches <- which(!is.na(match(data, medianValue)))
        allMatches[1]
}

distinct_function <- function(label, data) {
        print(label)
        row <- which.max(data[,3])
        v <- data[row,]
        print(sprintf("  Max in %s %s %d",v[,1],v[,2],v[,3]))
        row <- which.max(data[,4])
        v <- data[row,]
        print(sprintf("  Max out %s %s %d",v[,1],v[,2],v[,4]))

        row <- which.min(data[,3])
        v <- data[row,]
        print(sprintf("  Min in %s %s %d",v[,1],v[,2],v[,3]))
        row <- which.min(data[,4])
        v <- data[row,]
        print(sprintf("  Min out %s %s %d",v[,1],v[,2],v[,4]))

        row <- rowmedian(data[,3])
        v <- data[row,]
        print(sprintf("  Median in %s %s %d",v[,1],v[,2],v[,3]))
        row <- rowmedian(data[,4])
        v <- data[row,]
        print(sprintf("  Median out %s %s %d",v[,1],v[,2],v[,4]))
        print("")
}

distinct_module <- function(label, data) {
        print(label)
        row <- which.max(data[,2])
        v <- data[row,]
        print(sprintf("  Max in %s %d",v[,1],v[,2]))
        row <- which.max(data[,3])
        v <- data[row,]
        print(sprintf("  Max out %s %d",v[,1],v[,3]))

        row <- which.min(data[,2])
        v <- data[row,]
        print(sprintf("  Min in %s %d",v[,1],v[,2]))
        row <- which.min(data[,3])
        v <- data[row,]
        print(sprintf("  Min out %s %d",v[,1],v[,3]))

        row <- rowmedian(data[,2])
        v <- data[row,]
        print(sprintf("  Median in %s %d",v[,1],v[,2]))
        row <- rowmedian(data[,3])
        v <- data[row,]
        print(sprintf("  Median out %s %d",v[,1],v[,3]))
        print("")
}

dynamic_function <- function(label, data) {
        print(label)
        row <- which.max(data[,5])
        v <- data[row,]
        print(sprintf("  Max from %s %s -> %s %s  %s", v[1], v[2], v[3], v[4], v[5]))
        row <- which.min(data[,5])
        v <- data[row,]
        print(sprintf("  Min from %s %s -> %s %s  %s", v[1], v[2], v[3], v[4], v[5]))
        row <- rowmedian(data[,5])
        print(sprintf("  Median from %s %s -> %s %s  %s", v[1], v[2], v[3], v[4], v[5]))
        v <- data[row,]
}

# process data

print("-------------------------------")
print(sprintf("%s %s %s", experiment_name, location, type))
print("-------------------------------")

dynamic_function("Dynamic function calls", dynamic_function_calls)

distinct_function("Dynamic distinct function calls", dynamic_distinct_function_degree)
distinct_module("Dynamic distinct module calls", dynamic_distinct_module_degree)

if ( location == "combined-result" ) {
        distinct_function("Static distinct function calls", static_distinct_function_degree)
        distinct_module("Static distinct module calls", static_distinct_module_degree)
}

print("")
