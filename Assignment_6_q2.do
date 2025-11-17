* --------------------------------------------------------------
* Prerequisites
* --------------------------------------------------------------

* Clear workspace and set up environment
clear all
cls
cap set more off
set maxvar 32000

* Install necessary packages
local pkgs estout psmatch2 cem

foreach p of local pkgs {
    capture which `p'
    if _rc {
        display as text "Installing package: `p'"
        ssc install `p', replace
    }
    else {
        display as text "Package `p' already installed, updating to latest version"
        ssc install `p', replace
    }
}


* Load the dataset
use ps1_q2, clear
describe

* --------------------------------------------------------------
* Data Preparation
* --------------------------------------------------------------

* Define target (log of annual salary based on CP)
gen earnings = log(annual_salary)

* Define treatment (separation/mass layoff based on JLS)
gen displaced = (separation == 1 | mass_layoff == 1)

* Define covariates (gender, decile of 1995 earnings, and decade of birth)

** 1995 salary
gen earnings1995 = annual_salary if year == 1995
bysort id: egen earnings1995_all = max(earnings1995)
xtile earnings1995_decile = earnings1995_all, nq(10)

** Decade of birth
gen decade_brth = floor(year_brth/10)*10

** Define covariates
global covariates female earnings1995_decile decade_brth

* --------------------------------------------------------------
* Propensity Score Index (using data for year 1998)
* - optionally include argument "detail" (truncated for parsimony)
* - basis for Table 3, 4, 5, and 6
* --------------------------------------------------------------

pscore displaced $covariates if year == 1998, ///
 pscore(ps_1998_d) blockid(block_1998_d) comsup logit 
 
pscore separation $covariates if year == 1998, ///
 pscore(ps_1998_s) blockid(block_1998_s) comsup logit 
 
pscore mass_layoff $covariates if year == 1998, ///
 pscore(ps_1998_ml) blockid(block_1998_ml) comsup logit 

* --------------------------------------------------------------
* ATT Estimation with NN and Kernel Matching
* - basis for Table 7
* --------------------------------------------------------------

* Loop over years (as performed in CP)
levelsof year, local(years)

* Displaced
foreach y of local years {

    di "------------------------------------------------------"
    di " PROCESSING YEAR: `y' "
    di "------------------------------------------------------"

    * NN
    attnd earnings displaced $covariates ///
        if year == `y', comsup logit
    

    * Kernel
    attk earnings displaced $covariates ///
        if year == `y', comsup logit boot reps(10)
		

}
 
* Separation
foreach y of local years {

    di "------------------------------------------------------"
    di " PROCESSING YEAR: `y' "
    di "------------------------------------------------------"

    * NN
    attnd earnings separation $covariates ///
        if year == `y', comsup logit
    

    * Kernel
    attk earnings separation $covariates ///
        if year == `y', comsup logit boot reps(10)
		

}

* Mass Layoffs
foreach y of local years {

    di "------------------------------------------------------"
    di " PROCESSING YEAR: `y' "
    di "------------------------------------------------------"

    * NN
    attnd earnings mass_layoff $covariates ///
        if year == `y', comsup logit
    

    * Kernel
    attk earnings mass_layoff $covariates ///
        if year == `y', comsup logit boot reps(10)
		

}
 
 
* --------------------------------------------------------------
* Comparison of ATT Estimates
* - basis for Table 7 (manual input)
* - basis for Figures 1, 2
* --------------------------------------------------------------

* ----- Computation -----
 
* Displaced results in log earnings (manual input)
input year_d att_nn_d se_nn_d att_k_d se_k_d
1995 0.002 0.010 -0.016 0.012
1996 -0.007 0.007 -0.015 0.007
1997 -0.009 0.007 -0.016 0.006
1998 -0.023 0.007 -0.026 0.007
1999 -0.077 0.009 -0.077 0.006
2000 -0.103 0.010 -0.102 0.007
2001 -0.040 0.010 -0.037 0.010
end

gen nn_d_ci_low     = att_nn_d - 1.96*se_nn_d
gen nn_d_ci_high    = att_nn_d + 1.96*se_nn_d
gen k_d_ci_low      = att_k_d - 1.96*se_k_d
gen k_d_ci_high     = att_k_d + 1.96*se_k_d

* Displaced results in real earnings
quietly summarize annual_salary if year == 1999 & displaced == 0
scalar avg_slry_1995_d = r(mean)

gen att_nn_d_real        = (exp(att_nn_d) - 1) * avg_slry_1995_d
gen nn_d_ci_low_real     = (exp(att_nn_d - 1.96*se_nn_d) - 1) * avg_slry_1995_d
gen nn_d_ci_high_real    = (exp(att_nn_d + 1.96*se_nn_d) - 1) * avg_slry_1995_d

gen att_k_d_real		= (exp(att_k_d) - 1) * avg_slry_1995_d
gen k_d_ci_low_real     = (exp(att_k_d - 1.96*se_k_d) - 1) * avg_slry_1995_d
gen k_d_ci_high_real    = (exp(att_k_d + 1.96*se_k_d) - 1) * avg_slry_1995_d


* Separation results (manual input)
input year_s att_nn_s se_nn_s att_k_s se_k_s
1995 0.000 0.011 -0.011 0.010
1996 -0.002 0.007 -0.009 0.007
1997 -0.004 0.007 -0.008 0.009
1998 -0.022 0.007 -0.021 0.006
1999 -0.070 0.009 -0.067 0.010
2000 -0.099 0.010 -0.093 0.011
2001 -0.036 0.011 -0.029 0.007
end

gen nn_s_ci_low     = att_nn_s - 1.96*se_nn_s
gen nn_s_ci_high    = att_nn_s + 1.96*se_nn_s
gen k_s_ci_low     = att_k_s - 1.96*se_k_s
gen k_s_ci_high    = att_k_s + 1.96*se_k_s

* Separation results in real earnings
quietly summarize annual_salary if year == 1999 & separation == 0
scalar avg_slry_1995_s = r(mean)

gen att_nn_s_real        = (exp(att_nn_s) - 1) * avg_slry_1995_s
gen nn_s_ci_low_real     = (exp(att_nn_s - 1.96*se_nn_s) - 1) * avg_slry_1995_s
gen nn_s_ci_high_real    = (exp(att_nn_s + 1.96*se_nn_s) - 1) * avg_slry_1995_s

gen att_k_s_real		= (exp(att_k_s) - 1) * avg_slry_1995_s
gen k_s_ci_low_real     = (exp(att_k_s - 1.96*se_k_s) - 1) * avg_slry_1995_s
gen k_s_ci_high_real    = (exp(att_k_s + 1.96*se_k_s) - 1) * avg_slry_1995_s


* Mass Layoffs results (manual input)
input year_ml att_nn_ml se_nn_ml att_k_ml se_k_ml
1995 0.011 0.029 -0.053 0.025
1996 -0.037 0.022 -0.071 0.014
1997 -0.043 0.023 -0.076 0.020
1998 -0.030 0.022 -0.066 0.014
1999 -0.100 0.028 -0.139 0.033
2000 -0.107 0.030 -0.152 0.036
2001 -0.053 0.031 -0.103 0.035
end

gen nn_ml_ci_low     = att_nn_ml - 1.96*se_nn_ml
gen nn_ml_ci_high    = att_nn_ml + 1.96*se_nn_ml
gen k_ml_ci_low     = att_k_ml - 1.96*se_k_ml
gen k_ml_ci_high    = att_k_ml + 1.96*se_k_ml

* Mass Layoffs results in real earnings
quietly summarize annual_salary if year == 1999 & mass_layoff == 0
scalar avg_slry_1995_ml = r(mean)

gen att_nn_ml_real        = (exp(att_nn_ml) - 1) * avg_slry_1995_ml
gen nn_ml_ci_low_real     = (exp(att_nn_ml - 1.96*se_nn_ml) - 1) * avg_slry_1995_ml
gen nn_ml_ci_high_real    = (exp(att_nn_ml + 1.96*se_nn_ml) - 1) * avg_slry_1995_ml

gen att_k_ml_real		= (exp(att_k_ml) - 1) * avg_slry_1995_ml
gen k_ml_ci_low_real     = (exp(att_k_ml - 1.96*se_k_ml) - 1) * avg_slry_1995_ml
gen k_ml_ci_high_real    = (exp(att_k_ml + 1.96*se_k_ml) - 1) * avg_slry_1995_ml


 
* ----- Comparisons in Log Earnings -----
* Displacement Comparisons for NN
twoway ///
    (line att_nn_d year_d, lcolor(black) lwidth(medium) lpattern(solid) legend(label(1 "Displaced (Separation + Mass Layoff)"))) ///
	(rcap nn_d_ci_low nn_d_ci_high year_d, lcolor(black) legend(label(2 "Displaced 95% CI"))) ///
, ///
    ylabel(, angle(horizontal) grid) ///
    xlabel(1995(1)2001, grid) ///
    title("Earnings Losses Using NN Matching Estimator") ///
    ytitle("Change in Log Earnings (log $)") ///
    xtitle("Year") ///
    scheme(s1color)
	
capture graph export "NN_D_LOG.png", replace


* Separation and Mass Layoff Comparisons for NN
twoway ///
    (line att_nn_s year_s, lcolor(blue) lwidth(medium) lpattern(solid) legend(label(1 "Separation"))) ///
	(rarea nn_s_ci_low nn_s_ci_high year_s, color(blue%20) legend(label(2 "Separation 95% CI"))) ///
    (line att_nn_ml year_ml, lcolor(red) lwidth(medium) lpattern(solid) legend(label(3 "Mass Layoff"))) ///
	(rarea nn_ml_ci_low nn_ml_ci_high year_ml, color(red%20) legend(label(4 "Mass Layoff 95% CI"))) ///
, ///
    ylabel(, angle(horizontal) grid) ///
    xlabel(1995(1)2001, grid) ///
    title("Earnings Losses Using NN Matching Estimator") ///
    ytitle("Change in Log Earnings (log $)") ///
    xtitle("Year") ///
    scheme(s1color)	

capture graph export "NN_SML_LOG.png", replace
	
	
* Displacement Comparisons for Kernel
twoway ///
    (line att_k_d year_d, lcolor(black) lwidth(medium) lpattern(solid) legend(label(1 "Displaced (Separation + Mass Layoff)"))) ///
	(rcap k_d_ci_low k_d_ci_high year_d, lcolor(black) legend(label(2 "Displaced 95% CI"))) ///
, ///
    ylabel(, angle(horizontal) grid) ///
    xlabel(1995(1)2001, grid) ///
    title("Earnings Losses Using Kernel Matching Estimator") ///
    ytitle("Change in Log Earnings (log $)") ///
    xtitle("Year") ///
    scheme(s1color)
	
capture graph export "K_D_LOG.png", replace


* Separation and Mass Layoff Comparisons for Kernel
twoway ///
    (line att_k_s year_s, lcolor(blue) lwidth(medium) lpattern(solid) legend(label(1 "Separation"))) ///
	(rarea k_s_ci_low k_s_ci_high year_s, color(blue%20) legend(label(2 "Separation 95% CI"))) ///
    (line att_k_ml year_ml, lcolor(red) lwidth(medium) lpattern(solid) legend(label(3 "Mass Layoff"))) ///
	(rarea k_ml_ci_low k_ml_ci_high year_ml, color(red%20) legend(label(4 "Mass Layoff 95% CI"))) ///
, ///
    ylabel(, angle(horizontal) grid) ///
    xlabel(1995(1)2001, grid) ///
    title("Earnings Losses Using Kernel Matching Estimator") ///
    ytitle("Change in Log Earnings (log $)") ///
    xtitle("Year") ///
    scheme(s1color)	

capture graph export "K_SML_LOG.png", replace
	
	
* ----- Comparisons in Earnings -----
	
* Displacement Comparisons for NN
twoway ///
    (line att_nn_d_real year_d, lcolor(black) lwidth(medium) lpattern(solid) legend(label(1 "Displaced (Separation + Mass Layoff)"))) ///
	(rcap nn_d_ci_low_real nn_d_ci_high_real year_d, lcolor(black) legend(label(2 "Displaced 95% CI"))) ///
, ///
    ylabel(, angle(horizontal) grid) ///
    xlabel(1995(1)2001, grid) ///
    title("Earnings Losses Using NN Matching Estimator") ///
    ytitle("Change in Earnings ($)") ///
    xtitle("Year") ///
    scheme(s1color)
	
capture graph export "NN_D_REAL.png", replace


* Separation and Mass Layoff Comparisons for NN
twoway ///
    (line att_nn_s_real year_s, lcolor(blue) lwidth(medium) lpattern(solid) legend(label(1 "Separation"))) ///
	(rarea nn_s_ci_low_real nn_s_ci_high_real year_s, color(blue%20) legend(label(2 "Separation 95% CI"))) ///
    (line att_nn_ml_real year_ml, lcolor(red) lwidth(medium) lpattern(solid) legend(label(3 "Mass Layoff"))) ///
	(rarea nn_ml_ci_low_real nn_ml_ci_high_real year_ml, color(red%20) legend(label(4 "Mass Layoff 95% CI"))) ///
, ///
    ylabel(, angle(horizontal) grid) ///
    xlabel(1995(1)2001, grid) ///
    title("Earnings Losses Using NN Matching Estimator") ///
    ytitle("Change in Earnings ($)") ///
    xtitle("Year") ///
    scheme(s1color)	

capture graph export "NN_SML_REAL.png", replace

	
* Displacement Comparisons for Kernel
twoway ///
    (line att_k_d_real year_d, lcolor(black) lwidth(medium) lpattern(solid) legend(label(1 "Displaced (Separation + Mass Layoff)"))) ///
	(rcap k_d_ci_low_real k_d_ci_high_real year_d, lcolor(black) legend(label(2 "Displaced 95% CI"))) ///
, ///
    ylabel(, angle(horizontal) grid) ///
    xlabel(1995(1)2001, grid) ///
    title("Earnings Losses Using Kernel Matching Estimator") ///
    ytitle("Change in Earnings ($)") ///
    xtitle("Year") ///
    scheme(s1color)
	
capture graph export "K_D_REAL.png", replace


* Separation and Mass Layoff Comparisons for Kernel
twoway ///
    (line att_k_s_real year_s, lcolor(blue) lwidth(medium) lpattern(solid) legend(label(1 "Separation"))) ///
	(rarea k_s_ci_low_real k_s_ci_high_real year_s, color(blue%20) legend(label(2 "Separation 95% CI"))) ///
    (line att_k_ml_real year_ml, lcolor(red) lwidth(medium) lpattern(solid) legend(label(3 "Mass Layoff"))) ///
	(rarea k_ml_ci_low_real k_ml_ci_high_real year_ml, color(red%20) legend(label(4 "Mass Layoff 95% CI"))) ///
, ///
    ylabel(, angle(horizontal) grid) ///
    xlabel(1995(1)2001, grid) ///
    title("Earnings Losses Using Kernel Matching Estimator") ///
    ytitle("Change in Earnings ($)") ///
    xtitle("Year") ///
    scheme(s1color)	
	
capture graph export "K_SML_REAL.png", replace
