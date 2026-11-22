
seed_value <- 216

generate_dataset <- function(n, seed = seed_value, filename = "data.csv") {
  
  set.seed(seed)
  
  k <- 3
  cluster_centers <- data.frame(
    x = runif(k, 0, 10000),
    y = runif(k, 0, 10000)
  )
  
  cluster_id <- sample(1:k, n, replace = TRUE)
  
  coords <- data.frame(
    x = rnorm(n, mean = cluster_centers$x[cluster_id], sd = 800),
    y = rnorm(n, mean = cluster_centers$y[cluster_id], sd = 800)
  )
  

  depot <- c(mean(coords$x), mean(coords$y))
  
 
  dist_to_depot <- sqrt((coords$x - depot[1])^2 + (coords$y - depot[2])^2)
  
  dist_norm <- dist_to_depot / max(dist_to_depot)
  

  weights <- sample(2:15, n, replace = TRUE)
  
  base_profit <- weights * runif(n, 8, 15)
  
  penalty <- dist_norm * runif(n, 5, 20)
  
  profits <- round(base_profit - penalty)
  
  profits[profits < 5] <- sample(5:10, sum(profits < 5), replace = TRUE)
  
   capacity <- round(sum(weights) * 0.35)
  
  
  con <- file(filename, open = "w")
  
  writeLines(paste(n, capacity, sep = ","), con)
  writeLines(paste(profits, collapse = ","), con)
  writeLines(paste(weights, collapse = ","), con)
  writeLines(paste(round(depot[1],2), round(depot[2],2), sep=","), con)
  
  for(i in 1:n) {
    writeLines(paste(round(coords$x[i], 2), round(coords$y[i], 2), sep = ","), con)
  }
  
  close(con)
  
  cat("Dataset written to:", filename, "\n")
}

generate_dataset(10, seed_value, "small.csv")
generate_dataset(30, seed_value, "medium.csv")
generate_dataset(70, seed_value, "large.csv")
