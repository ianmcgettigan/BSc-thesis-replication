*********************************************************
*********************************************************
*                  DEWORMING AND TRUST					*
*					 PROGRAMS DOFILE                    *		
***      created by Ian McGettigan in May 2025       ****
** last & once for all modified by Ian on May 2025     **
*********************************************************
*********************************************************

**## Correlation table

** NOTE: The following code produces the correct numbers which is most 
** important for reproducibility. 
** It does not produce exaclty the table I have produced.
** The exact code for that table I modified ex-post and it can
** be viewed in the repository. 

** note for me: tables per round correspond to tables A9--A11 in Alfonsi

cap program drop	correlations
program define 		correlations
		
	cap erase "$tables/$tablename.tex"	
	
	foreach outcome in  $outcomes_corr {
		eststo: estpost corr `outcome' $covariates_corr

	}	
	

	esttab using "$tables/$tablename.tex", replace ///
			b(%5.3f) se(%5.3f) nogaps star(* 0.1 ** 0.05 *** 0.01) ///
			nocons nolz noobs title("Human capital and measures of trust: Descriptive evidence") ///
			label se nonumbers longtable 
										
	estimates clear	
	
	
	loc heterogeneity $het1 $het2 
	foreach het of local heterogeneity {

		if     "`het'" == "$het1" {
				local letter "B" 
				local label "Panel B: Sample - $panelB"
				local table age
		}
		else if "`het'" == "$het2" {
				local letter "C"
				local label "Panel C: Sample - $panelC"
				local table age
		}
				
		foreach outcome in   $outcomes_corr {
		eststo: estpost corr `outcome' $covariates_corr if `het'==1 

		}		
	
	esttab using "$tables/$tablename.tex", append ///
			b(%5.3f) se(%5.3f) nogaps star(* 0.1 ** 0.05 *** 0.01) ///
			nomtitles nocons noobs nolz ///
			label se nonumbers longtable ///
			addnote("Very long note that I hope gets wrapped cus otherwise I will be very very very very very very mad" ///
			"even madder still I don't think I made the note long enough but here we go let's see what happens!")
											
	estimates clear
				
	}	
		
end

**## OLS Regression Table
cap program drop 	regressions
program define 		regressions
		
		
	cap erase "$tables/$tablename.tex"
	estimates clear
	
	foreach outcome of varlist $outcomes {		
		
		* save percentiles for trimming					
		sum `outcome', d
		
		*control mean & sd - not trimmed
		sum `outcome' if psdp_treat == 0 [aw=con_weight] 
		loc controlMean = r(mean)
		loc controlSD = r(sd)
				
		* Pooled OLS estimator
		eststo: reg `outcome' psdp_treat $controls  [pw=con_weight] ,  cluster(con_psdpsch98) 
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
					

				

		esttab using "$tables/$tablename.tex", ///
				b(%5.3f) se(%5.3f) r2 nogaps star(* 0.1 ** 0.05 *** 0.01) ///
				nomtitles nocons nolz label se noobs nonumbers replace longtable ///
				keep(psdp_treat) stats(control_mean control_SD t_effect r2 N_ind N, ///
				labels("Control Mean" "Control SD" "Treatment Effect (\%)" "R-squared" "Number Individuals" "Number Observations") fmt(2 2 2 2 0)) ///
				substitute("Standard errors in parentheses" " ""\sym{*} \(p<.10\), \sym{**} \(p<.05\), \sym{***} \(p<.01\)" " ") ///					

		estimates clear
			
		
		loc heterogeneity 	$het1 $het2 
		foreach het of local heterogeneity {

						if     "`het'" == "$het1" {
								local letter "B" 
								local label "Panel B: Sample - $panelB"
								local table age
						}
						else if "`het'" == "$het2" {
								local letter "C"
								local label "Panel C: Sample - $panelC"
								local table age
						}
				
			foreach outcome of varlist $outcomes {		
						su `outcome', d
						*control mean & sd - not trimmed
						sum `outcome' if psdp_treat == 0 & `het' == 1 [aw=con_weight] 
						loc controlMean = r(mean)
						loc controlSD = r(sd)
					* Pooled OLS estimator by gender
						eststo: reg `outcome' psdp_treat $controls  if `het'==1 [pw=con_weight] ,  cluster(con_psdpsch98)  
							loc treat = _b[psdp_treat]
						estadd scalar control_mean = `controlMean'
						estadd scalar control_SD = `controlSD'
						estadd loc Controls Yes, replace
						loc teffect = 100*(`treat'/`controlMean')
						estadd scalar t_effect = round(`teffect', .01)	
						** saving number of unique pupid observations in regression sample
							preserve
							keep if e(sample)
							bysort pupid (pupid): gen c`outcome' = 1 if _n==1 
							summ c`outcome'
							estadd scalar N_ind = r(N)
							restore		
					}
						
		# delimit ;
				esttab using "$tables/$tablename.tex", 
				b(%5.3f) se(%5.3f) r2 nogaps star(* 0.1 ** 0.05 *** 0.01)
				nomtitles nocons nolz 
				label se noobs nonumbers append longtable 
				keep(psdp_treat) 
				stats(control_mean control_SD t_effect r2 N_ind N, 
						labels("Control Mean" "Control SD" "Treatment Effect (\%)" "R-squared" "Number Individuals" "Number Observations") fmt(2 2 2 2 0))
				substitute("Standard errors in parentheses" " "
										"\sym{*} \(p<.10\), \sym{**} \(p<.05\), \sym{***} \(p<.01\)" " ")						
			;
			#delimit cr		
			estimates clear
			eststo clear	

		}	 
		
		end
		
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
			b(%5.3f) se(%5.3f) r2 nogaps star(* 0.1 ** 0.05 *** 0.01)
			nomtitles nocons nolz 
			title(Deworming Treatment and Importance of Religion)
			label se noobs nonumbers collabels(none) replace longtable fragment nomtitles booktabs
			mgroups("\vspace{-.4cm}\\ \toprule \vspace{-.4cm} \\ &\multicolumn{7}{c}{\emph{\textbf{KLPS `i' - `label'}}} \\ \toprule   \\ \mainHeaderTone", span) 
			keep(psdp_treat) 
			stats(control_mean control_SD t_effect r2 N_ind N, 
			labels("Control Mean" "Control SD" "Treatment Effect (\%)" "R-squared" "Number Individuals" "Number Observations") fmt(2 2 2 2 0))
			substitute("Standard errors in parentheses" " " "\sym{*} \(p<.10\), \sym{**} \(p<.05\), \sym{***} \(p<.01\)" " ")						
			;
			#delimit cr	
			
			estimates clear
		}	

		
		
		
		
		