****************************************************************
****************************************************************
**               ON THE DETERMINANTS OF TRUST                 **
**                REGRESSIONS MASTER DO FILE                  **
****************************************************************
****************************************************************

/* BY: IAN MCGETTIGAN
JUNE 2025
---
NOTE: I follow a lot of the method used in Alfonsi et al. (2024).
Thank you to the authors for making their replication package public.
Thank you to Hao Wang for their excellent code.
*/

*** NOTES FOR ME !!!!
*** So this creates all the correct numbers in tables_and_figures as
*** Reg_round1, 2, 3. I merged them all into a nice graph called Reg.tex.

* PREAMBLE

global dir "~/Documents/bsc3/sem2/bscthesis" // change to where data and do are

cd $dir 

cap mkdir "$dir/tables_and_figures"

global data   = "$dir/data"
global do     =   "$dir/do"
global tables = "$dir/tables_and_figures"

clear all
clear matrix
set more off
set maxvar 32000
set varabbrev on



**## Regressions by round

	use "$data/KLPS.dta", clear
		
		global outcomes 	   "trust_general trust_tribe trust_othertribes trust_church trust_otherchurch"
		global controls  	   "con_cost_sharing con_saturation_dm con_demeaned_popT_6k con_zoneidI2-con_zoneidI8 con_pup_pop con_month_interviewI1_KLPS con_month_interviewI2_KLPS con_month_interviewI3_KLPS con_month_interviewI4_KLPS con_month_interviewI5_KLPS con_month_interviewI6_KLPS con_month_interviewI7_KLPS con_month_interviewI8_KLPS con_month_interviewI9_KLPS con_month_interviewI10_KLPS con_month_interviewI11_KLPS con_month_interviewI12_KLPS  con_std98_base_I2 -con_std98_base_I6 con_avgtest96 con_wave2  female voced"
		
		forval i=1(1)3 { //survey rounds 1 to 3
			
			cap erase "$tables/Reg_round`i'.tex"
			estimates clear
		
			foreach outcome of varlist $outcomes {		
				* save percentiles for trimming					
				sum `outcome', d
				
				*control mean & sd - not trimmed
				sum `outcome' if psdp_treat == 0 & survey_round==`i'  [aw=con_weight] 
				loc controlMean = r(mean)
				loc controlSD = r(sd)
				
				* Pooled OLS estimator
				eststo: reg `outcome' psdp_treat $controls  [pw=con_weight] if survey_round==`i' ,  cluster(con_psdpsch98) 
				loc treat = _b[psdp_treat]
				estadd scalar control_mean = `controlMean'
				estadd scalar control_SD   = `controlSD'
				estadd loc Controls Yes, replace
				loc teffect = 100*(`treat'/`controlMean')
				estadd scalar t_effect = round(`teffect', .01)	
				
				* saving number of unique pupid observations in regression sample
				preserve
					keep if e(sample)
					bysort pupid (pupid): gen c`outcome' = 1 if _n==1 
					summ c`outcome'
					estadd scalar N_ind = r(N)
				restore	
			}
							
				
			# delimit ;
			esttab using "$tables/Reg_round`i'.tex", 
			b(%5.3f) se(%5.3f) r2 nogaps star(* 0.1 ** 0.05 *** 0.01) ///
			nomtitles nocons nolz label se noobs nonumbers replace longtable ///
			title(Deworming Treatment and Trust) ///
			keep(psdp_treat) 
			stats(control_mean control_SD t_effect r2_a N_ind, 
			labels("Control Mean" "Control SD" "Treatment Effect (\%)" "adj. R-squared" "Observations") fmt(2 2 2 2 0))
			substitute("Standard errors in parentheses" " " "\sym{*} \(p<.10\), \sym{**} \(p<.05\), \sym{***} \(p<.01\)" " ")						
			;
			#delimit cr	
			
			estimates clear
		}	
		
		// heterogeneity: Older vs Younger
		
		local heterogeneity older younger
		
		forval i=1(1)3 {
			forval j=0(1)1 { //older vs younger
				
				cap erase "$tables/Reg_round`i'_`het'.tex"
				estimates clear
				
				foreach outcome of varlist $outcomes {	
					
					* save percentiles for trimming					
					sum `outcome', d
					
					*control mean & sd - not trimmed
					sum `outcome' if psdp_treat == 0 & survey_round==`i' & older==`j'  [aw=con_weight]
					loc controlMean = r(mean)
					loc controlSD = r(sd)
					
					* Pooled OLS estimator
					eststo: reg `outcome' psdp_treat $controls  [pw=con_weight] if survey_round==`i' & older==`j' ,  cluster(con_psdpsch98) 
					loc treat = _b[psdp_treat]
					estadd scalar control_mean = `controlMean'
					estadd scalar control_SD   = `controlSD'
					estadd loc Controls Yes, replace
					loc teffect = 100*(`treat'/`controlMean')
					estadd scalar t_effect = round(`teffect', .01)	
						
					* saving number of unique pupid observations in regression sample
					preserve
						keep if e(sample)
						bysort pupid (pupid): gen c`outcome' = 1 if _n==1 
						summ c`outcome'
						estadd scalar N_ind = r(N)
					restore	
				}
				
				// 1 = older; 0 = younger
				
				# delimit ;
				esttab using "$tables/Reg_round`i'_`j'.tex", 
				b(%5.3f) se(%5.3f) r2 nogaps star(* 0.1 ** 0.05 *** 0.01) ///
				nomtitles nocons nolz label se noobs nonumbers replace longtable ///
				title(Deworming Treatment and Trust by Age) ///
				keep(psdp_treat) 
				stats(control_mean control_SD t_effect r2_a N_ind, 
				labels("Control Mean" "Control SD" "Treatment Effect (\%)" "adj. R-squared" "Observations") fmt(2 2 2 2 0))
				substitute("Standard errors in parentheses" " " "\sym{*} \(p<.10\), \sym{**} \(p<.05\), \sym{***} \(p<.01\)" " ")						
				;
				#delimit cr	
			
				estimates clear
				
			} 
			
		}
		
		// Heterogeneity: Male vs Female; male = 1
		
		gen male = female + 1
		recode male 2=0
		
		local heterogeneity male female
		
		forval i=1(1)3 {
			forval j=0(1)1 { 
				
				cap erase "$tables/Reg_round`i'_sex`het'.tex"
				estimates clear
				
				foreach outcome of varlist $outcomes {	
					
					* save percentiles for trimming					
					sum `outcome', d
					
					*control mean & sd - not trimmed
					sum `outcome' if psdp_treat == 0 & survey_round==`i' & male==`j'  [aw=con_weight]
					loc controlMean = r(mean)
					loc controlSD = r(sd)
					
					* Pooled OLS estimator
					eststo: reg `outcome' psdp_treat $controls  [pw=con_weight] if survey_round==`i' & male==`j' ,  cluster(con_psdpsch98) 
					loc treat = _b[psdp_treat]
					estadd scalar control_mean = `controlMean'
					estadd scalar control_SD   = `controlSD'
					estadd loc Controls Yes, replace
					loc teffect = 100*(`treat'/`controlMean')
					estadd scalar t_effect = round(`teffect', .01)	
						
					* saving number of unique pupid observations in regression sample
					preserve
						keep if e(sample)
						bysort pupid (pupid): gen c`outcome' = 1 if _n==1 
						summ c`outcome'
						estadd scalar N_ind = r(N)
					restore	
				}
				
				// 1 = male ; 0 = female
				
				# delimit ;
				esttab using "$tables/Reg_round`i'_sex`j'.tex", 
				b(%5.3f) se(%5.3f) r2 nogaps star(* 0.1 ** 0.05 *** 0.01) ///
				nomtitles nocons nolz label se noobs nonumbers replace longtable ///
				title(Deworming Treatment and Trust by Sex) ///
				keep(psdp_treat) 
				stats(control_mean control_SD t_effect r2_a N_ind, 
				labels("Control Mean" "Control SD" "Treatment Effect (\%)" "adj. R-squared" "Observations") fmt(2 2 2 2 0))
				substitute("Standard errors in parentheses" " " "\sym{*} \(p<.10\), \sym{**} \(p<.05\), \sym{***} \(p<.01\)" " ")						
				;
				#delimit cr	
			
				estimates clear
				
			}
		}
		
		// Heterogeneity: High vs Low educ; 1 = above-median education
		
		gen high_educ=0
		replace high_educ=1 if cov_eduattainment_KLPS3 >= 10
		
		local heterogeneity high_educ 
		
		forval i=1(1)3 {
			forval j=0(1)1 { 
				
				cap erase "$tables/Reg_round`i'_educ`het'.tex"
				estimates clear
				
				foreach outcome of varlist $outcomes {	
					
					* save percentiles for trimming					
					sum `outcome', d
					
					*control mean & sd - not trimmed
					sum `outcome' if psdp_treat == 0 & survey_round==`i' & high_educ==`j'  [aw=con_weight]
					loc controlMean = r(mean)
					loc controlSD = r(sd)
					
					* Pooled OLS estimator
					eststo: reg `outcome' psdp_treat $controls  [pw=con_weight] if survey_round==`i' & high_educ==`j' ,  cluster(con_psdpsch98) 
					loc treat = _b[psdp_treat]
					estadd scalar control_mean = `controlMean'
					estadd scalar control_SD   = `controlSD'
					estadd loc Controls Yes, replace
					loc teffect = 100*(`treat'/`controlMean')
					estadd scalar t_effect = round(`teffect', .01)	
						
					* saving number of unique pupid observations in regression sample
					preserve
						keep if e(sample)
						bysort pupid (pupid): gen c`outcome' = 1 if _n==1 
						summ c`outcome'
						estadd scalar N_ind = r(N)
					restore	
				}
				
				// // // // // // // // // // // // // // // // // // // // // 
				
				# delimit ;
				esttab using "$tables/Reg_round`i'_educ`j'.tex", 
				b(%5.3f) se(%5.3f) r2 nogaps star(* 0.1 ** 0.05 *** 0.01) ///
				nomtitles nocons nolz label se noobs nonumbers replace longtable ///
				title(Deworming Treatment and Trust by Educational Attainment) ///
				keep(psdp_treat) 
				stats(control_mean control_SD t_effect r2_a N_ind, 
				labels("Control Mean" "Control SD" "Treatment Effect (\%)" "adj. R-squared" "Observations") fmt(2 2 2 2 0))
				substitute("Standard errors in parentheses" " " "\sym{*} \(p<.10\), \sym{**} \(p<.05\), \sym{***} \(p<.01\)" " ")						
				;
				#delimit cr	
			
				estimates clear
				
			}
		}
		
	
		
clear all
exit
