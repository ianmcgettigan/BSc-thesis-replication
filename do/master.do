*********************************************************
*********************************************************
*                  DEWORMING AND TRUST					*
*					  MASTER DOFILE                     *		
***      		Last modified in May 2025        	 ****
*********************************************************
*********************************************************

********************************************************************************
** NOTE: THE METHOD IN THIS `.do' FILE AND ALL CORRESPONDING `.do' FILES *******
** ARE LARGELY TAKEN FROM ALFONSI ET AL. (2024). 						 *******
** ALL CREDIT GOES TO THEM IN THIS CORRELATIONAL AND REGRESSION DESIGN.  *******
** SPECIAL THANKS TO TILL WICKER FOR HELPING EXPLAIN SOME OF THE CODE    *******
** ALL MISTAKES ARE MY OWN												 *******
********************************************************************************

****************
**# Initialize
****************

clear all
clear matrix
set more off
set maxvar 32000
set varabbrev on
	
*********************
**# Set Directories	
*********************

global dir "~/Documents/bsc3/sem2/bscthesis" // Change to your working directory

* Make folder for tables and figures
cap mkdir "$dir/tables_and_figures"

global data   = "$dir/data"
global do     =   "$dir/do"
global tables = "$dir/tables_and_figures"


****************** 
**# Run do file
******************


* Figures, correlation tables, and regression tables
do "$do/analysis.do"

**********
**# Exit
**********
clear all
exit
