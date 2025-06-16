# Replication Data and Code for my BSc Thesis #

Replication data and code for ON THE DETERMINANTS OF TRUST: CAUSAL EVIDENCE FROM KENYA. 

---

## How to use ##

1. Clone this repository or download it as a `.zip` file where you wish to
   store the figures, tables, etc.
2. Ensure you have a LaTeX distribution installed on your machine and
   ensure you have STATA installed. 
3. Change directory into `.do` in your STATA console. Run `do filename.do`
   for each `.do` file. Do not run `programs.do` or `analysis.do`; these
       are called by `master.do`. Each file will reproduce the correct values
       for the tables and figures seen in my paper; it will not, however,
           format the tables as shown in my paper. This was done by me
           manually. But the values are the same, which is the main thing.
4. `pvals.do` outputs to your clipboard the p-values for the regression.
   Run it separately for each form of heterogeneity, then paste the
   p-values when prompted after running `qvals.do` to get the FDR-adjusted
   p-values. If you use Windows, edit the code accordingly; I believe you
   will have to change `pbcopy` to `clip`.
