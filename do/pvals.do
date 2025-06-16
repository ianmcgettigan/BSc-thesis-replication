****************************************************************
****************************************************************
**               ON THE DETERMINANTS OF TRUST                 **
**                     P-VALUES DO FILE                       **
****************************************************************
****************************************************************

/*
This `.do' file prints raw p-values that are used in the sharpened q-value
correction by Anderson and BKY. Code is my own. If you're using windows,
you will need to change line 52 to shell echo "`pvals'" | clip
*/

* PREAMBLE *** IMPORTANT NOTE: RUN THE CODE PER SUBSECTION; COMMENT OUT THE REST

global dir "~/Documents/bsc3/sem2/bscthesis" // change to where data and do are

cd $dir 

global data   = "$dir/data"

clear all
clear matrix
set more off
set maxvar 32000
set varabbrev on

use "$data/KLPS.dta", clear

		global outcomes 	   "trust_general trust_tribe trust_othertribes trust_church trust_otherchurch"
		global controls  	   "con_cost_sharing con_saturation_dm con_demeaned_popT_6k con_zoneidI2-con_zoneidI8 con_pup_pop con_month_interviewI1_KLPS con_month_interviewI2_KLPS con_month_interviewI3_KLPS con_month_interviewI4_KLPS con_month_interviewI5_KLPS con_month_interviewI6_KLPS con_month_interviewI7_KLPS con_month_interviewI8_KLPS con_month_interviewI9_KLPS con_month_interviewI10_KLPS con_month_interviewI11_KLPS con_month_interviewI12_KLPS  con_std98_base_I2 -con_std98_base_I6 con_avgtest96 con_wave2  female voced"
		
**## p-values by round in the full sample.

		preserve
		
		local pvals
		
		forval i=1(1)3 {
			
			foreach outcome of varlist $outcomes {
				
				quietly reg `outcome' psdp_treat $controls  [pw=con_weight] if survey_round==`i' ,  cluster(con_psdpsch98) 
				matrix T = r(table)
				local c = colnumb(r(table), "psdp_treat")
				scalar pval = T[4, `c']
				local pvals "`pvals' `=pval'"
			}
		
		}
		
		shell echo "`pvals'" | pbcopy // more efficient I think
		// if you're on windows, change the above to shell echo "`pvals'" | clip
		// display "Treatment p-values: `pvals'"
		
		restore
		
**## p-values by round by heterogeneity: Older vs younger

		preserve
		
		local pvals
		local heterogeneity older younger
		
		forval i=1(1)3 {
			forval j=0(1)1 { 
			
			foreach outcome of varlist $outcomes {
				
				quietly reg `outcome' psdp_treat $controls  [pw=con_weight] if survey_round==`i' & older==`j',  cluster(con_psdpsch98) 
				matrix T = r(table)
				local c = colnumb(r(table), "psdp_treat")
				scalar pval = T[4, `c']
				local pvals "`pvals' `=pval'"
				
				}
			}
		}
		
		shell echo "`pvals'" | pbcopy // more efficient I think
		// if you're on windows, change the above to shell echo "`pvals'" | clip
		// display "Treatment p-values: `pvals'"
		
		restore
		
**## p-values by round by heterogeneity: Male vs Female

		preserve
		
		gen male = female + 1
		recode male 2=0
		
		local pvals
		local heterogeneity male female
		
		forval i=1(1)3 {
			forval j=0(1)1 { 
			
			foreach outcome of varlist $outcomes {
				
				quietly reg `outcome' psdp_treat $controls  [pw=con_weight] if survey_round==`i' & male==`j',  cluster(con_psdpsch98) 
				matrix T = r(table)
				local c = colnumb(r(table), "psdp_treat")
				scalar pval = T[4, `c']
				local pvals "`pvals' `=pval'"
				
				}
			}
		}
		
		shell echo "`pvals'" | pbcopy // more efficient I think
		// if you're on windows, change the above to shell echo "`pvals'" | clip
		// display "Treatment p-values: `pvals'"
		
		restore
		
**## p-values by round by heterogeneity: high educ vs low educ

		preserve
		
		gen high_educ=0
		replace high_educ=1 if cov_eduattainment_KLPS3 >= 10
		
		local pvals
		local heterogeneity high_educ
		
		forval i=1(1)3 {
			forval j=0(1)1 { 
			
			foreach outcome of varlist $outcomes {
				
				quietly reg `outcome' psdp_treat $controls  [pw=con_weight] if survey_round==`i' & high_educ==`j',  cluster(con_psdpsch98) 
				matrix T = r(table)
				local c = colnumb(r(table), "psdp_treat")
				scalar pval = T[4, `c']
				local pvals "`pvals' `=pval'"
				
				}
			}
		}
		
		shell echo "`pvals'" | pbcopy // more efficient I think
		// if you're on windows, change the above to shell echo "`pvals'" | clip
		// display "Treatment p-values: `pvals'"
		
		restore


clear all
exit
