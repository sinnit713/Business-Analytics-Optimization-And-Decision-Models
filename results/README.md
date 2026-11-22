# Results and Analysis

This document presents the results of the three decision-making problems covered in the Data-Driven Decision Making (D3M) Assignment 2. The results are based on the analyses and findings reported in the assignment.

---

## 1. Last-Mile Delivery Planning During the IPL Season

The two-stage optimisation framework was evaluated using Local Search (LS) and Genetic Algorithm (GA) across small, medium and large datasets.

The algorithms were assessed based on total profit, transportation cost and computational time.

### 1.1 Comparative Performance of LS and GA

| Dataset | Method | Profit | Transportation Cost | Time (seconds) |
|---|---|---:|---:|---:|
| Small | LS | 168 | 432.81 | 0.0922 |
| Small | GA | 234 | 450.85 | 0.3415 |
| Medium | LS | 1,010 | 526.71 | 0.0075 |
| Medium | GA | 1,141 | 620.88 | 0.3398 |
| Large | LS | 2,608 | 1,093.71 | 0.0763 |
| Large | GA | 2,588 | 1,522.52 | 0.4351 |

### 1.2 Key Findings

- **Small dataset:** GA achieved a higher profit of 234 compared with 168 for LS, but also resulted in a higher transportation cost.
- **Medium dataset:** GA achieved a higher profit of 1,141 compared with 1,010 for LS, although its transportation cost was also higher.
- **Large dataset:** LS performed better in both profit and transportation cost, achieving a profit of 2,608 compared with 2,588 for GA.
- **Computational time:** LS was faster than GA across all three datasets.

A representative feasible route obtained in the small instance was:

`Depot → Customer 6 → Customer 4 → Customer 3 → Customer 5 → Customer 9 → Depot`

### 1.3 Conclusion

The results indicate that there was no single dominant algorithm across all datasets. GA achieved higher profits in the small and medium instances, whereas LS performed better in the large dataset in terms of both profit and transportation cost. LS also consistently required less computational time.

The findings highlight the importance of considering profitability, routing efficiency and computational practicality together.

---

## 2. Evaluating Hospital Performance

Hospital performance was evaluated using an integrated framework combining the Analytic Hierarchy Process (AHP) and Data Envelopment Analysis (DEA).

AHP was used to assess hospitals according to managerial priorities, while DEA measured their relative operational efficiency.

### 2.1 AHP Criteria Weights

| Criterion | Weight |
|---|---:|
| Cost Efficiency | 0.106 |
| Service Quality | 0.633 |
| Service Output | 0.260 |

The AHP analysis assigned the highest priority to Service Quality, followed by Service Output and Cost Efficiency.

### 2.2 AHP Hospital Ranking

| Rank | Hospital | AHP Score |
|---:|---|---:|
| 1 | H7 | 0.1199 |
| 2 | H2 | 0.1169 |
| 3 | H5 | 0.1113 |
| 4 | H8 | 0.1098 |
| 5 | H6 | 0.1093 |
| 6 | H3 | 0.1092 |
| 7 | H4 | 0.1089 |
| 8 | H1 | 0.1074 |
| 9 | H9 | 0.1072 |

### 2.3 DEA Efficiency Results

The DEA model used an input-oriented CCR approach assuming Constant Returns to Scale (CRS).

**Inputs:** Staff, Beds and Cost.

**Outputs:** Patients Treated, Surgeries Performed and Recovery Rate.

| Hospital | DEA Efficiency Score |
|---|---:|
| H3 | 1.000 |
| H8 | 1.000 |
| H2 | 0.991 |
| H6 | 0.975 |
| H7 | 0.973 |
| H5 | 0.969 |
| H4 | 0.933 |
| H1 | 0.894 |
| H9 | 0.883 |

Hospitals H3 and H8 achieved an efficiency score of 1.000 and were classified as fully efficient units on the efficiency frontier.

### 2.4 Comparative Analysis: AHP vs DEA

| Hospital | AHP Result | DEA Result | Key Insight |
|---|---|---:|---|
| H7 | Rank 1 | 0.973 | High scale and output, but not frontier-efficient |
| H3 | Rank 6 | 1.000 | Highly efficient, but lower total scale |
| H8 | Rank 4 | 1.000 | Balanced strategic and efficient performer |
| H2 | Rank 2 | 0.991 | Strong across both methods |

### 2.5 Conclusion

The AHP and DEA results provide complementary perspectives on hospital performance. AHP prioritised H7, H2 and H5, while DEA identified H3 and H8 as fully efficient hospitals.

The findings demonstrate that high performance does not necessarily indicate high operational efficiency. The integration of both approaches provides a more well-rounded assessment for hospital resource allocation.

The report recommends a tiered approach to resource allocation, with primary expansion funding focused on H2 and H8.

---

## 3. Strategic Vendor Selection for E-Commerce Expansion

The strategic vendor selection problem was evaluated using a combination of the Analytic Hierarchy Process (AHP) and Goal Programming (GP).

AHP was used to establish the relative importance of the decision criteria, while Goal Programming determined the optimal vendor combination based on the specified operational targets.

### 3.1 AHP Criteria Weights

| Criterion | Weight | Rank |
|---|---:|---:|
| Delivery Performance | 0.433 | 1 |
| Flexibility | 0.287 | 2 |
| Operational Risk | 0.184 | 3 |
| Cost Efficiency | 0.097 | 4 |

The consistency ratio (CR) was 0.026, which was below the accepted threshold of 0.10.

### 3.2 Operational Targets

| Goal | Target |
|---|---:|
| Daily Deliveries | At least 20,000 |
| Total Investment | At most ₹500 Lakhs |
| Service Level | At least 80 |
| Risk Exposure | At most 55 |
| Flexibility | Preferably 75 or above |

### 3.3 Optimal Vendor Selection

The Goal Programming model was implemented in R using the `ompr` and `ROI.plugin.glpk` packages.

The optimal solution reported was:

| Decision Variable | Value |
|---|---:|
| Vendor A (xA) | 1 |
| Vendor B (xB) | 1 |
| Vendor C (xC) | 0 |

**Selected Vendors: Vendor A + Vendor B**

The report states that this combination achieved the minimum weighted deviation of **4.351**.

### 3.4 Performance Against Targets

| Performance Measure | Result | Target | Status |
|---|---:|---:|---|
| Daily Deliveries | 20,000 | ≥ 20,000 | Achieved |
| Total Cost (₹ Lakhs) | 530 | ≤ 500 | Exceeded by 30 |
| Average Service Score | 80.0 | ≥ 80 | Achieved |
| Average Risk Score | 52.5 | ≤ 55 | Achieved |
| Average Flexibility Score | 72.5 | ≥ 75 | Shortfall of 2.5 |

### 3.5 Key Findings

The selected combination of Vendor A and Vendor B satisfies the primary operating requirements while resulting in two deviations:

- **Budget Overspend:** Total investment exceeds the preferred budget by ₹30 Lakhs.
- **Flexibility Shortfall:** Average flexibility is 72.5, which is 2.5 points below the preferred target of 75.

The selected combination achieves the required delivery capacity and service performance while maintaining risk exposure within the specified target.

### 3.6 Conclusion

The Goal Programming analysis recommends a two-vendor strategy consisting of Vendor A and Vendor B for ShopKart's initial expansion into Tier-2 cities.

The combination provides the required delivery capacity, service performance and operational risk levels, with a budget overspend and a small flexibility shortfall.

---

## Overall Conclusion

The three problems demonstrate the application of quantitative decision-making techniques to logistics optimisation, healthcare performance evaluation and strategic vendor selection.

The analyses highlight the importance of balancing competing objectives, operational constraints and managerial priorities when making business decisions.

**Methods applied:**
- Local Search (LS)
- Genetic Algorithm (GA)
- Analytic Hierarchy Process (AHP)
- Data Envelopment Analysis (DEA)
- Goal Programming (GP)

**Tools:** R Programming and associated optimisation and analytical packages.
