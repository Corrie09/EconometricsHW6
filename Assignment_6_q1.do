clear all
import delimited "ps1_q1.csv", clear

* Question1

keep if time == 1

bysort treat: summarize teacher_attendance
bysort treat: summarize students

tabstat teacher_attendance students, by(treat) stats(mean sd n)

* outreg2 using baseline.tex, replace tex(frag) ///
    sum(log) eqkeep(mean) ///
    keep(teacher_attendance students)     --> if you want to save the table 
	
* Question2

clear all
import delimited "ps1_q1.csv", clear

keep if time > 1
tabstat teacher_attendance, by(treat) stats(mean sd n)

reg teacher_attendance treat

