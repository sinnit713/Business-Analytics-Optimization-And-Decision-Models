# Business Analytics: Optimisation and Decision Models
My MSc Business Analytics coursework covering last mile delivery optimisation, hospital performance evaluation using AHP and DEA, and strategic vendor selection using Goal Programming.

## Project Overview

This repository covers three business decision-making problems using optimisation techniques, multi-criteria decision analysis, and mathematical modelling.

### 1. Delivery Optimisation

Implements a two-stage last-mile delivery planning approach:

- **Order Selection:** Local Search (LS) and Genetic Algorithm (GA).
- **Route Planning:** Local Search (LS) and Genetic Algorithm (GA).
- Evaluates profit, transportation cost, and computational time across small, medium, and large datasets.

### 2. Hospital Performance Evaluation

Applies analytical decision-making techniques to evaluate hospital performance:

- Analytic Hierarchy Process (AHP) for criteria prioritisation.
- Data Envelopment Analysis (DEA) for efficiency measurement.
- Comparative evaluation of hospital performance.

### 3. Strategic Vendor Selection

Develops a structured vendor selection model:

- AHP for determining decision criteria priorities.
- Goal Programming for evaluating operational targets and trade-offs.
- Assessment of cost, delivery performance, flexibility, and operational risk.

## Repository Structure

```text
├── data/
│   ├── delivery_optimisation/
│   │   ├── data_file_generation_delivery_optimisation.R
│   │   ├── small.csv
│   │   ├── medium.csv
│   │   └── large.csv
│   │
│   ├── hospital_performance/
│   │   └── hospital_performance.csv
│   │
│   └── vendor_selection/
│       ├── vendor_performance.csv
│       └── vendor_operational_contribution.csv
│
├── scripts/
│   ├── delivery_optimisation.R
│   ├── hospital_performance.R
│   └── vendor_selection.R
│
├── results/
│   └── README.md
│
└── README.md
```

## Tools and Techniques

- **Programming:** R
- **Optimisation:** Local Search, Genetic Algorithm, Goal Programming
- **Decision Analysis:** Analytic Hierarchy Process (AHP)
- **Efficiency Analysis:** Data Envelopment Analysis (DEA)
- **Data Management:** CSV datasets

## Requirements

- [R Programming Language](https://www.r-project.org/)
- Required R packages:

```r
install.packages(c(
  "GA",
  "AHPtools",
  "Benchmarking",
  "ompr",
  "ompr.roi",
  "ROI.plugin.glpk",
  "dplyr"
))
```

Load the packages required by the respective scripts before execution.

## Reproducibility

The repository separates datasets, R scripts, and results to support clear project organisation and reproducibility.

The delivery optimisation folder also includes the R script used to generate the small, medium, and large datasets. Refer to the individual scripts for implementation details and execution requirements.

## Academic Context

MSc Business Analytics  
Queen’s University Belfast
