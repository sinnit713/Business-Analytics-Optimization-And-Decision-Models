
# D3M Assignment: Hospital Performance Evaluation
# Combined Analytical Script: AHP + DEA

#
# Code Development Declaration:
# This script was primarily developed and structured by us based on
# lecture materials, assignment requirements, and independent analysis.
#
# External support tools (including Generative AI) were used only for:
# - Clarifying R syntax
# - Debugging minor errors
# - Explaining selected package functions
# - Improving comments formatting
#
# All modelling decisions, assumptions, criteria selection,
# pairwise comparisons, input-output definitions, calculations,
# and final interpretations were independently reviewed,
# adapted, and validated by us.


# SECTION 1: LOAD REQUIRED LIBRARIES

# Package used for AHP related utilities (core calculations manual)
library(AHPtools)

# Package used for DEA implementation in R
library(Benchmarking)


# SECTION 2: COMMON DATASET
# Dataset entered manually from assignment question table

hospital_data <- data.frame(
  Hospital = paste0("H", 1:9),
  Staff = c(120,155,95,130,140,105,170,100,135),
  Beds = c(80,100,65,85,90,70,110,68,88),
  Cost = c(150,210,110,170,185,130,230,120,175),
  Patients = c(900,1250,820,1000,1100,860,1350,850,980),
  Surgeries = c(300,370,270,310,340,285,400,295,305),
  Recovery = c(92,89,95,91,88,96,87,94,90)
)

cat("Hospital Dataset:\n")
print(hospital_data)


# SECTION 3: AHP ANALYSIS
cat("PART A: AHP ANALYSIS\n")

# Step 1: Pairwise Comparison Matrix
# Order: Cost Efficiency, Service Quality, Service Output
# Values selected using Saaty's scale based on assignment context

criteria_mat <- matrix(c(
  1,   1/5, 1/3,
  5,   1,   3,
  3,   1/3, 1
), nrow = 3, byrow = TRUE)

colnames(criteria_mat) <- c("Cost", "Quality", "Output")
rownames(criteria_mat) <- c("Cost", "Quality", "Output")

cat("\nPairwise Comparison Matrix:\n")
print(criteria_mat)

# Step 2: Normalize Matrix
# Standard AHP column normalization from lecture method

col_sums <- colSums(criteria_mat)
norm_mat <- sweep(criteria_mat, 2, col_sums, "/")

cat("\nNormalized Matrix:\n")
print(round(norm_mat, 3))

# Step 3: Compute Criteria Weights
# Row-average approach

weights <- rowMeans(norm_mat)

cat("\nCriteria Weights:\n")
print(round(weights, 3))

# Step 4: Consistency Check
ws_vector <- criteria_mat %*% weights
lambda_vals_ahp <- ws_vector / weights
lambda_max <- mean(lambda_vals_ahp)

n <- nrow(criteria_mat)
CI <- (lambda_max - n) / (n - 1)

RI <- 0.58
CR <- CI / RI

cat("\nLambda Values:\n")
print(round(lambda_vals_ahp, 3))

cat("\nLambda Max:", round(lambda_max, 3), "\n")
cat("Consistency Index (CI):", round(CI, 4), "\n")
cat("Consistency Ratio (CR):", round(CR, 4), "\n")

if (CR < 0.10) {
  cat("Consistency Check: ACCEPTABLE\n")
} else {
  cat("Consistency Check: NOT ACCEPTABLE\n")
}


# Step 5: Alternative Level Evaluation
# Calculate totals for normalization
total_patients <- sum(hospital_data$Patients)
total_surgeries <- sum(hospital_data$Surgeries)
total_recovery <- sum(hospital_data$Recovery)

# Cost efficiency assumption:
# Lower cost implies higher efficiency
hospital_data$Cost_Eff <- 1 / hospital_data$Cost
hospital_data$Cost_Eff <- hospital_data$Cost_Eff /
  sum(hospital_data$Cost_Eff)

# Normalize quality components
hospital_data$Recovery_norm <- hospital_data$Recovery /
  total_recovery

hospital_data$Surgery_norm <- hospital_data$Surgeries /
  total_surgeries

# Recovery weighted higher than surgeries
hospital_data$Quality <- (0.7 * hospital_data$Recovery_norm) +
  (0.3 * hospital_data$Surgery_norm)

# Service output based on patients treated
hospital_data$Output <- hospital_data$Patients /
  total_patients

# Step 6: Final AHP Score
w_cost <- weights[1]
w_quality <- weights[2]
w_output <- weights[3]

hospital_data$AHP_Score <- (w_cost * hospital_data$Cost_Eff) +
  (w_quality * hospital_data$Quality) +
  (w_output * hospital_data$Output)

hospital_data <- hospital_data[order(-hospital_data$AHP_Score), ]
hospital_data$AHP_Rank <- 1:nrow(hospital_data)

cat("\nAHP Final Ranking:\n")
print(hospital_data[, c("Hospital",
                        "Cost_Eff",
                        "Quality",
                        "Output",
                        "AHP_Score",
                        "AHP_Rank")])

# SECTION 4: DEA ANALYSIS
# Model: CCR (CRS), Input-Oriented

cat("PART B: DEA ANALYSIS\n")

# Step 1: Define Inputs and Outputs
# Hospitals treated as Decision Making Units (DMUs)

inputs <- as.matrix(
  hospital_data[, c("Staff", "Beds", "Cost")]
)

outputs <- as.matrix(
  hospital_data[, c("Patients", "Surgeries", "Recovery")]
)

rownames(inputs) <- hospital_data$Hospital
rownames(outputs) <- hospital_data$Hospital

# Step 2: Run DEA Model
# Objective: Minimise inputs while maintaining outputs

dea_result <- dea(
  X = inputs,
  Y = outputs,
  RTS = "crs",
  ORIENTATION = "in"
)

# Step 3: Efficiency Scores
# Score = 1 indicates efficient hospital

eff_scores <- efficiencies(dea_result)

cat("\nDEA Efficiency Scores:\n")
print(round(eff_scores, 3))


# Step 4: Identify Efficient Hospitals

efficient_units <- which(round(eff_scores, 3) == 1)

cat("\nEfficient Hospitals:\n")
print(rownames(inputs)[efficient_units])

# Step 5: Peer Reference (Lambda Values)

lambda_vals <- lambda(dea_result)

cat("\nPeer Weights (Lambda Matrix):\n")
print(round(lambda_vals, 3))

# SECTION 5: COMPARISON OF AHP AND DEA


cat("PART C: COMPARISON OF RESULTS\n")

comparison <- data.frame(
  Hospital = hospital_data$Hospital,
  AHP_Rank = hospital_data$AHP_Rank,
  AHP_Score = round(hospital_data$AHP_Score, 4),
  DEA_Score = round(eff_scores[hospital_data$Hospital], 3)
)

print(comparison)

# End of script
