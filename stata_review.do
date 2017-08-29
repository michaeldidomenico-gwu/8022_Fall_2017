*Comment one line

/*comment bracket
   can break
     over multiple
	   lines*/

/*If you will be writing a lot, you can change the delimiter so you can
write long instead of wide. This only works in the do file. Or you can use 
3 slashes (///) to indicate the line is continuing, but it will not allow
for extra spacing*/
#delimit ;
#delimit cr

/*general syntax:
[by varlist:] function/command [varlist] [in range] [if expression] , [options]

make good use of comments and spacing to make your programs more readable to others

if you want to indent, always use the space bar and not tab because different text 
editors will treat tabs differently, but spaces are always treated the same

Give some info at the top of the program to let others know what to do. It does not
have to be this detailed but should at least have your name the date and the purpose*/

/*****************************************************************************/
*File name:   H:\stata_review.do
*Programmer:  Michael DiDomenico
*Date:        9-7-16
*Input:       auto.dta
*Output:      n/a
*Description: Short description of what the program does, if it needs to be run 
*             in sequence with other programs, things to watch out for, etc
*Changes:     Important to track big changes if not using version control
*             software so you can more easily find what is causing errors from
*             previous versions.
/*****************************************************************************/

*clear the system
capture log close
clear
set more off

*link to your working directory
cd H:\

*open a log file
log using "stata_review.log", replace

/*usually you can -use- a stata dataset, this is sysuse because it is a play file*/
use auto

/*you can use the browse command to open the data table, but you need to close the 
table before doing anything esle

You also can look at listings of variable for a few observations is you want to see
what they look like. The in...says in observations 1 through 5*/
list wage-married in 1/5

/*a couple of ways to get descriptive data with describe, summarize, and tabulate*/
describe   
summarize  
/*note that you can abbreviate commands, so sum for summarize, tab for tabulate, etc.*/
sum wage
sum wage, detail
sum wage if numdep!=0
/*better than below--why? Don't forget that  missings are treated as infinity*/
sum wage if numdep>0

/*also note that you use the == instead of =*/
sum wage if married==1

/*two ways of grouping by values of a variable: using the sort command and by:
or using bysort :*/
sort nonwhite
by nonwhite: sum wage

bysort nonwhite: sum wage

/*some examples of tabulating variables and two-way tables*/
tabulate numdep
tab numdep,missing
tab female married
tab female married,column row



*to drop variables, use drop. to create variables use gen or egen
*gen is for simple formulas/transformations; multiplication, addition
*egen can apply functions across groups; max, mean
drop lwage expersq tenursq

/*can look to see the distribution of wage and see that a transformation may
be helpful, so generate the log of wage*/
histogram wage,normal
gen lwage=log(wage)
histogram lwage

gen expersq=exper^2
gen tenuresq=tenure^2
list wage lwage exper expersq tenure tenuresq in 1/5 

egen minwage=min(wage)
list wage-tenure minwage in 1/5

/*shorthand for generating dummies, but make sure it is doing what you think it is.
a good practice is to cross-tab the old variable and new variable to check for accuracy*/
gen highered=(educ>12)
tab educ highered,missing

*use replace if the variable exists
gen edlevel=.
replace edlevel=1 if educ>0 & educ<=8 
replace edlevel=2 if educ>8 & educ<=12
replace edlevel=3 if educ>12 
tab educ edlevel
tab educ edlevel,m

/*can give the values labels, here I am writing over several lines by switching the delimiter
First define the value labesl*/
#d ;
label define edlevel_l   
   1 "Less than High School"       
   2 "Some High School"   
   3 "Post Secondary";
#d cr

/*then apply the labels to the variable*/
label values edlevel edlevel_l
des edlevel
tab educ

/*You can collapse variables across groups, for example summing earnings among a group, but
notice that this creates a shorter dataset*/
collapse (mean)wage, by(edlevel)
des
list
graph bar wage edlevel

/*Stata only stores one dataset at a time, may need to switch back to the full dataset*/
use wage1, clear

/*you can use graph and twoway to make simple graphs, scatterplots, etc*/
twoway (scatter wage exper) (lfit wage exper)

/*regression is regression or reg the left hand side variable, then the right hand side variables.
This regresses wage on experience*/
regress wage exper

/*You can output residuals or other things. The variable name you want to create comes before the
comma, and the type of value comes after the comma. xb is the coefficient, residual is the residual*/

predict wagehat, xb
predict resid, residuals
twoway scatter resid exper

/*you can specify robust errors two ways. First, you can add 'robust' after the comma in a regression
or you can use vce(robust), which gives you a little more flexibility if you need to change the type
of variance covariance estimator*/
reg wage exper, vce(robust)

/*now with multiple regression*/
reg wage exper educ, robust

/*use the test command right after running the regression to test if parameters are equal to one
another or if they are equal to some value. For example if the coefficients on experience and 
education are equal or if the coefficient on experience is equal to .01*/
test exper=educ
test exper=.01

/*you can use adjust to predict at a certain value--or you can plug in values to the output equation*/
adjust exper=15

/*if you know a command and want description of syntax, available options, output, etc you can use the 
inline help command*/
help regress

/*these are a few online resources I use, but there are many others*/
*http://www.stata.com/links/resources-for-learning-stata/
*http://www.ats.ucla.edu/stat/stata
*http://data.princeton.edu/stata/

/*When you are done, make sure to close your log and clear memory in case you want to do something else*/
capture log, close
clear
