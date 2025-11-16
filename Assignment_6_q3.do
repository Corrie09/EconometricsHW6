use "ps1_q3.dta", clear

* Question 1

* OLS model
reg workedm kidcount agem blackm hispm othracem


* probit model
probit workedm kidcount agem blackm hispm othracem
margins, dydx(*)



* Question 2

* First-stage (linear): check relevance of instrument
reg kidcount twin_latest agem blackm hispm othracem


* IV-Probit estimation (endogenous kidcount instrumented by twin_latest)
ivprobit workedm (kidcount = twin_latest) agem blackm hispm othracem, vce(robust)

* Average (or conditional) marginal effects after ivprobit
margins, dydx(kidcount) predict(pr)



* Question 3

* Marginal effects evaluated at integer values of kidcount (1 through 6), probability scale
margins, dydx(kidcount) at(kidcount=(1(1)6)) predict(pr)

* Plot the marginal effects (with 95% CI)
marginsplot, xdimension(kidcount) yline(0) ///
    title("Average marginal effects of kidcount with 95% CIs") ///
    ytitle("Marginal effect on Pr(workedm=1)") xtitle("KIDCOUNT") ///
    scheme(s1color)

* Save the plot for LaTeX
graph export "kidcount_margins_plot.png", replace
