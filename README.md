# Econometrics HW6

## Overview

This folder contains all materials required for the Econometrics Assignment. It includes:

- **PDF report** with analytical answers and all required figures/tables
- **Stata do-files** used for data preparation, estimation, and figure generation
- **Dataset(s)** required to run the code

## Folder Structure

```
project_folder/
├── Assignment_Report.pdf
├── Assignment_6_q3.do
├── ps1_q3.dta
└── README.md
```

## Questions Covered

- Question 1
- Question 2
- Question 3

## Q1

### Requirements

- Stata 17 or later

### How to Run the Code

1. Open Stata
2. Set the working directory to the project folder
3. Run the do-file: `Assignment_6_q1.do`

The script will automatically:
- Load the dataset `ps1_q1.csv`
- Generate baseline means for teacher attendance and student attendance (Question 1.1)
- Estimate the post-treatment effect of the program using OLS with clustered standard errors (Question 1.2)
- Produce all required tables for inclusion in the report

### Notes
- The script requires no manual input once the working directory is correctly set.
- Ensure that `ps1_q1.csv` is located in the correct folder relative to the `.do` file or adjust the file path accordingly.



## Q2

### Requirements

- Stata 17 or later

### How to Run the Code

1. Open Stata
2. Set the working directory to the project folder
3. Run the do-file: `Assignment_6_q2.do`

The script will automatically:
- Install necessary packages if not yet installed
- Load the dataset `ps1_q2.csv` aka the VWH subsample data
- Set up data for propensity score matching following JLS and CP
- Generate propensity score index for each treament-- displaced, separated, mass layoff-- and produce the necessary tables (3, 4, 5, 6) and diagnostics (Question 2.1)
- Estimate the ATT through NN and kernel estimation (10 bootstrap samples) for the CP estimator and produce the necessary tables (7) (Question 2.2)
- Summarize the computed ATT and prepare the data for visualization
- Visualize the differences (figures 1, 2) in ATT for the different estimators and treatments for comparison to JLS model (Question 2.3)

### Notes
- The tables used in the comparison of ATT estimates section is based on the (manually) aggregated output from the loops run previously. This is not generated automatically due to the volume of code as of the moment.
- Ensure that `ps1_q2.csv` is located in the correct folder relative to the `.do` file or adjust the file path accordingly.
- All graphs generated are automatically saved in the folder as a .jpg file. If the file already exists, it will not run into an error.

## Q3 

### Requirements

- Stata 17 or later

### How to Run the Code

1. Open Stata
2. Set the working directory to the project folder
3. Run the do-file: `Assignment_6_q3.do`

The script will automatically:
- Load the data
- Prepare variables
- Run OLS/IV/Probit models
- Compute marginal effects
- Generate all required figures and tables

### Notes

- The code is written for Stata 17+ and runs without errors as long as the folder structure remains unchanged
- Paths in the do-file assume the working directory is set to the project root
