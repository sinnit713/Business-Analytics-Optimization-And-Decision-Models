
# Question 3: Strategic Vendor Selection for ShopKart
#
# Code Development Declaration:
# This script was primarily developed by us using
# lecture materials, assignment requirements, and personal analysis.
#
# Lecture based code structures were adapted for:
# - AHP matrix calculations and consistency testing
# - Goal Programming formulation using ompr / ROI / GLPK
#
# Generative AI tools were used in a limited support capacity for:
# - Explaining coding syntax and debugging support
# - Improving code comments and presentation clarity
# - Discussing modelling logic (AHP + Goal Programming integration)
#
# All final modelling decisions, assumptions, pairwise judgments,
# data inputs, interpretation, and submitted code structure were
# reviewed, modified, and validated by the student.

# AHP helper function written by student using lecture method:
# column normalization -> row averages -> CI -> CR
calculate_ahp <- function(mat, ri_value) {
  
  # Column sums
  col_sums <- colSums(mat)
  
  # Normalized matrix
  norm_mat <- sweep(mat, 2, col_sums, "/")
  
  # Priority weights (row averages)
  weights <- rowMeans(norm_mat)
  
  # Weighted sum vector
  ws_vector <- mat %*% weights
  
  # Lambda max
  lambda_max <- mean(ws_vector / weights)
  
  # Consistency Index
  n <- nrow(mat)
  ci <- (lambda_max - n) / (n - 1)
  
  # Consistency Ratio
  cr <- ci / ri_value
  
  return(list(
    col_sums = col_sums,
    norm_mat = norm_mat,
    weights = weights,
    lambda_max = lambda_max,
    ci = ci,
    cr = cr
  ))
}


# Pairwise comparison values chosen by us based on
# assignment stakeholder priorities and business judgement.

criteria_mat <- matrix(c(
  1,   1/4, 1/3, 1/2,
  4,   1,   2,   2,
  3,   1/2, 1,   2,
  2,   1/2, 1/2, 1
), nrow = 4, byrow = TRUE)

rownames(criteria_mat) <- c("Cost", "Delivery", "Flexibility", "Risk")
colnames(criteria_mat) <- c("Cost", "Delivery", "Flexibility", "Risk")

# Display matrix
cat(" Criteria Pairwise Comparison Matrix \n")
print(criteria_mat)

# Saaty Random Index for n = 4
RI_4 <- 0.90

# STEP 3: Run AHP Calculation for Criteria Matrix

result_criteria <- calculate_ahp(criteria_mat, RI_4)

# Display column sums
cat("\n Column Sums \n")
print(round(result_criteria$col_sums, 3))

# Display normalized matrix
cat("\n Normalized Matrix \n")
print(round(result_criteria$norm_mat, 3))

# Display weights
cat("\n Criteria Weights \n")
print(round(result_criteria$weights, 3))

# Add names to weights
names(result_criteria$weights) <- c("Cost", "Delivery", "Flexibility", "Risk")

# Ranked weights
cat("\n Ranked Priorities \n")
print(sort(round(result_criteria$weights, 3), decreasing = TRUE))

# STEP 4: Consistency Check

cat("\n Consistency Check \n")

cat("Lambda Max =", round(result_criteria$lambda_max, 3), "\n")
cat("Consistency Index (CI) =", round(result_criteria$ci, 3), "\n")
cat("Consistency Ratio (CR) =", round(result_criteria$cr, 3), "\n")

# Decision Rule
if(result_criteria$cr <= 0.10) {
  cat("Status: ACCEPTABLE (Judgments are consistent)\n")
} else {
  cat("Status: REVISE MATRIX (Judgments are inconsistent)\n")
}

# PART B: Goal Programming for Vendor Selection
# (Continue below AHP in same file)

# STEP 1: Load Required Packages

library(ompr)
library(ompr.roi)
library(ROI.plugin.glpk)
library(dplyr)


# STEP 2: Vendor Data
# Vendors:
# 1 = Vendor A
# 2 = Vendor B
# 3 = Vendor C

deliveries <- c(8000, 12000, 10000)
cost       <- c(180, 350, 260)
service    <- c(70, 90, 80)
flexibility<- c(85, 60, 75)
risk       <- c(65, 40, 50)


# STEP 3: Goal Targets

target_delivery    <- 20000
target_budget      <- 500
target_service     <- 80
target_risk        <- 55
target_flexibility <- 75

# STEP 4: AHP Weights (from previous section)

w_cost        <- result_criteria$weights["Cost"]
w_delivery    <- result_criteria$weights["Delivery"]
w_flexibility <- result_criteria$weights["Flexibility"]
w_risk        <- result_criteria$weights["Risk"]

# Use delivery weight also for service goal
w_service <- w_delivery

# STEP 5: Build Weighted Goal Programming Model
# Goal Programming model adapted from lecture examples,
# reformulated by student for ShopKart vendor selection case.
model_gp <- MIPModel() %>%
  
  # Decision Variables (1 = selected, 0 = not selected)
  add_variable(x[i], i = 1:3, type = "binary") %>%
  
  # Deviation Variables
  add_variable(d_minus[j], j = 1:5, lb = 0) %>%
  add_variable(d_plus[j],  j = 1:5, lb = 0) %>%
  
  # Goal 1: Deliveries >= 20000
  add_constraint(
    sum_expr(deliveries[i] * x[i], i = 1:3) +
      d_minus[1] - d_plus[1] == target_delivery
  ) %>%
  
  # Goal 2: Budget <= 500
  add_constraint(
    sum_expr(cost[i] * x[i], i = 1:3) +
      d_minus[2] - d_plus[2] == target_budget
  ) %>%
    
  # Goal 3: Average Service >= 80
  add_constraint(
    sum_expr(service[i] * x[i], i = 1:3) +
      d_minus[3] - d_plus[3] ==
      target_service * sum_expr(x[i], i = 1:3)
  ) %>%
  
  # Goal 4: Average Risk <= 55
  add_constraint(
    sum_expr(risk[i] * x[i], i = 1:3) +
      d_minus[4] - d_plus[4] ==
      target_risk * sum_expr(x[i], i = 1:3)
  ) %>%
  
  # Goal 5: Average Flexibility >= 75
  add_constraint(
    sum_expr(flexibility[i] * x[i], i = 1:3) +
      d_minus[5] - d_plus[5] ==
      target_flexibility * sum_expr(x[i], i = 1:3)
  ) %>%
  

  # At least one vendor must be selected
  add_constraint(sum_expr(x[i], i = 1:3) >= 1)

# STEP 6: Objective Function and Solve Model

model_gp <- model_gp %>%
  
  # Objective weights derived from AHP results computed in Part A.
  set_objective(
    
    w_delivery    * d_minus[1] +   # delivery shortfall
      w_cost        * d_plus[2]  +   # budget excess
      w_service     * d_minus[3] +   # service shortfall
      w_risk        * d_plus[4]  +   # risk excess
      w_flexibility * d_minus[5],    # flexibility shortfall
    
    "min"
  )

# Solve Model
result_gp <- solve_model(model_gp, with_ROI("glpk"))

# STEP 7: Display Optimal Solution
cat(" Goal Programming Optimal Solution\n")

# Selected Vendors
solution_x <- get_solution(result_gp, x[i])

cat("\nSelected Vendors:\n")
print(solution_x)

# Deviations
cat("\nDeviation Variables:\n")
print(get_solution(result_gp, d_minus[j]))
print(get_solution(result_gp, d_plus[j]))

# Objective Value
cat("\nMinimum Objective Value:\n")
print(objective_value(result_gp))

# Final recommendation summary written by us
# based on optimisation output.
selected <- solution_x$value

cat(" Final Recommendation\n")

if(selected[1] == 1) cat("Vendor A Selected\n")
if(selected[2] == 1) cat("Vendor B Selected\n")
if(selected[3] == 1) cat("Vendor C Selected\n")

cat("\nReason:\n")
cat("- Combination gives best compromise across all goals.\n")
cat("- Balances delivery volume, service quality, cost, and risk.\n")
cat("- Based on AHP priorities and Goal Programming optimisation.\n")

# STEP 9: Final Performance Summary

x_val <- solution_x$value

final_delivery <- sum(deliveries * x_val)
final_cost <- sum(cost * x_val)

vendors_selected <- sum(x_val)

final_service <- sum(service * x_val) / vendors_selected
final_risk <- sum(risk * x_val) / vendors_selected
final_flexibility <- sum(flexibility * x_val) / vendors_selected


cat(" Performance Summary\n")

cat("Total Deliveries :", final_delivery, "\n")
cat("Total Cost       :", final_cost, "\n")
cat("Avg Service      :", round(final_service,2), "\n")
cat("Avg Risk         :", round(final_risk,2), "\n")
cat("Avg Flexibility  :", round(final_flexibility,2), "\n")

