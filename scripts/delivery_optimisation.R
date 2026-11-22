
# Assignment: Last Mile Delivery Planning during IPL Season
# Module: Data Driven Decision Making (D3M)
#
# Methods adapted:
# - Local Search (LS)
# - Genetic Algorithm (GA package)

# Author written
# Purpose: Read dataset file and extract orders, capacity,
# profits, weights, depot, and customer coordinates.
read_dataset <- function(file_path) {
  
  data <- read.csv(file_path, header = FALSE)
  
  # Row 1
  n <- as.numeric(data[1,1])
  capacity <- as.numeric(data[1,2])
  
  # Row 2 & 3
  profits <- as.numeric(data[2, 1:n])
  weights <- as.numeric(data[3, 1:n])
  
  # Row 4 (Depot)
  depot <- as.numeric(data[4, 1:2])
  
  # Remaining rows (Coordinates)
  coordinates <- data[5:(n+4), 1:2]
  coordinates <- apply(coordinates, 2, as.numeric)
  
  return(list(
    n = n,
    capacity = capacity,
    profits = profits,
    weights = weights,
    depot = depot,
    coordinates = coordinates
  ))
}


# Adapted from lecture materials
# Purpose: Evaluate knapsack solution and reject infeasible
# solutions exceeding vehicle capacity.
eval_knapsack <- function(x, profits, weights, capacity) {
  
  total_weight <- sum(x * weights)
  
  if (total_weight > capacity) {
    return(-1)   # Reject infeasible
  }
  
  return(sum(x * profits))
}

# Adapted from lecture materials
# Purpose: Generate neighbouring solution using 1-bit flip.
neighbor_knapsack <- function(x) {
  
  idx <- sample(1:length(x), 1)
  x[idx] <- 1 - x[idx]
  
  return(x)
}

# Adapted from lecture materials
# Modified for assignment dataset
# Purpose: Solve Stage 1 order selection using Local Search.
local_search_knapsack <- function(profits, weights, capacity, max_iter = 100) {
  
  set.seed(123)

  current_sol <- rep(0, length(profits))
  current_fit <- eval_knapsack(current_sol, profits, weights, capacity)
  
  for (i in 1:max_iter) {
    
    next_sol <- neighbor_knapsack(current_sol)
    next_fit <- eval_knapsack(next_sol, profits, weights, capacity)
    
    if (next_fit > current_fit) {
      current_sol <- next_sol
      current_fit <- next_fit
    }
  }
  
  return(list(
    solution = current_sol,
    profit = current_fit,
    weight = sum(current_sol * weights)
  ))
}

# External package used for Genetic Algorithm implementation
library(GA)

# Adapted from lecture materials and GA package examples
# Parameters adjusted by student
# Purpose: Solve Stage 1 order selection using Genetic Algorithm.
ga_knapsack <- function(profits, weights, capacity) {
  
  eval_func <- function(x) {
    total_weight <- sum(x * weights)
    
    if (total_weight > capacity) {
      return(-1)
    }
    
    return(sum(x * profits))
  }
  
  set.seed(123)
  
  ga_run <- ga(
    type = "binary",
    fitness = eval_func,
    nBits = length(profits),
    popSize = 30,
    maxiter = 50,
    pcrossover = 0.8,
    pmutation = 0.1,
    elitism = 1,
    monitor = FALSE
  )
  
  solution <- ga_run@solution[1,]
  profit <- ga_run@fitnessValue
  weight <- sum(solution * weights)
  
  return(list(
    solution = solution,
    profit = profit,
    weight = weight
  ))
}

# Author-written
# Purpose: Compute Euclidean distance matrix for routing stage.
compute_distance_matrix <- function(nodes) {
  
  n <- nrow(nodes)
  dist_matrix <- matrix(0, n, n)
  
  for (i in 1:n) {
    for (j in 1:n) {
      
      dist_matrix[i, j] <- sqrt(
        (nodes[i,1] - nodes[j,1])^2 +
          (nodes[i,2] - nodes[j,2])^2
      )
      
    }
  }
  
  return(dist_matrix)
}

# Adapted from lecture TSP logic
# Purpose: Compute total route distance including return to depot.
eval_tsp <- function(route, dist_matrix) {
  
  cost <- 0
  for (i in 1:(length(route) - 1)) {
    cost <- cost + dist_matrix[route[i], route[i+1]]
  }
  
  # Return to depot (complete cycle)
  cost <- cost + dist_matrix[route[length(route)], route[1]]
  
  return(cost)
}

# Adapted from lecture local search concept
# Purpose: Generate neighbouring route by swapping two nodes.
swap_neighbor <- function(route) {
  
  idx <- sample(1:length(route), 2)
  
  temp <- route[idx[1]]
  route[idx[1]] <- route[idx[2]]
  route[idx[2]] <- temp
  
  return(route)
}

# Adapted from lecture materials
# Purpose: Solve routing problem using Local Search.
local_search_tsp <- function(dist_matrix, max_iter = 200) {
  
  set.seed(123)
  n <- nrow(dist_matrix)
  
  current_route <- sample(1:n)
  current_cost <- eval_tsp(current_route, dist_matrix)
  
  for (i in 1:max_iter) {
    
    next_route <- swap_neighbor(current_route)
    next_cost <- eval_tsp(next_route, dist_matrix)
    
    if (next_cost < current_cost) {
      current_route <- next_route
      current_cost <- next_cost
    }
  }
  
  return(list(
    route = current_route,
    distance = current_cost
  ))
}

# Author written
# Purpose: Reorder route so that it starts from depot (node 1).
normalize_route <- function(route) {
  
  start_idx <- which(route == 1)
  return(c(route[start_idx:length(route)],
           route[1:(start_idx - 1)]))
}

# Adapted from lecture GA routing logic
# Purpose: Fitness function for TSP (negative distance).
fitness_tsp <- function(route, dist_matrix) {
  
  cost <- 0
  for (i in 1:(length(route) - 1)) {
    cost <- cost + dist_matrix[route[i], route[i+1]]
  }
  
  cost <- cost + dist_matrix[route[length(route)], route[1]]
  return(-cost)  # GA maximizes
}

# Adapted from lecture materials and GA package examples
# Purpose: Solve routing problem using Genetic Algorithm.
ga_tsp_run <- function(dist_matrix) {
  
  set.seed(123)
  n <- nrow(dist_matrix)
  
  ga_run <- ga(
    type = "permutation",
    fitness = function(route) fitness_tsp(route, dist_matrix),
    lower = 1,
    upper = n,
    popSize = 50,
    maxiter = 50,
    monitor = FALSE
  )
  
  best_route <- ga_run@solution[1,]
  best_distance <- -ga_run@fitnessValue
  
  return(list(
    route = best_route,
    distance = best_distance
  ))
}


# Author written with AI assisted modular structuring
# Purpose: Execute full two stage optimization for one dataset,
# including timing, cost calculation, and summary output.
run_pipeline <- function(file_path, dataset_name) {
  
  # 1. Read Data
  data <- read_dataset(file_path)
  profits <- data$profits
  weights <- data$weights
  capacity <- data$capacity
  
  # Stage 1: LS 
  start_ls <- Sys.time()
  result_ls <- local_search_knapsack(profits, weights, capacity)
  end_ls <- Sys.time()
  time_ls <- as.numeric(difftime(end_ls, start_ls, units="secs"))
  
  selected_ls <- which(result_ls$solution == 1)
  nodes_ls <- rbind(data$depot, data$coordinates[selected_ls, ])
  dist_ls <- compute_distance_matrix(nodes_ls)
  
  start_tsp_ls <- Sys.time()
  tsp_ls <- local_search_tsp(dist_ls)
  end_tsp_ls <- Sys.time()
  time_tsp_ls <- as.numeric(difftime(end_tsp_ls, start_tsp_ls, units="secs"))
  
  # Stage 2:  GA 
  start_ga <- Sys.time()
  result_ga <- ga_knapsack(profits, weights, capacity)
  end_ga <- Sys.time()
  time_ga <- as.numeric(difftime(end_ga, start_ga, units="secs"))
  
  selected_ga <- which(result_ga$solution == 1)
  nodes_ga <- rbind(data$depot, data$coordinates[selected_ga, ])
  dist_ga <- compute_distance_matrix(nodes_ga)
  
  start_tsp_ga <- Sys.time()
  tsp_ga <- ga_tsp_run(dist_ga)
  end_tsp_ga <- Sys.time()
  time_tsp_ga <- as.numeric(difftime(end_tsp_ga, start_tsp_ga, units="secs"))
  
  # Costs
  cost_ls <- 0.02 * tsp_ls$distance
  cost_ga <- 0.02 * tsp_ga$distance
  
  # Total Time
  total_time_ls <- time_ls + time_tsp_ls
  total_time_ga <- time_ga + time_tsp_ga
  
  # Final Table
  return(data.frame(
    Dataset = dataset_name,
    Method = c("LS", "GA"),
    Profit = c(result_ls$profit, result_ga$profit),
    Cost = c(cost_ls, cost_ga),
    Time = c(total_time_ls, total_time_ga)
  ))
}

# Main execution: run all datasets and combine results
result_small <- run_pipeline("data/delivery_optimisation/small.csv", "Small")
result_medium <- run_pipeline("data/delivery_optimisation/medium.csv", "Medium")
result_large <- run_pipeline("data/delivery_optimisation/large.csv", "Large")

final_results <- rbind(result_small, result_medium, result_large)
final_results$Cost <- round(final_results$Cost, 2)
final_results$Time <- round(final_results$Time, 4)


print(final_results)

