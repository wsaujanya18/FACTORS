*-------------------------------------------------------------------------------
* Project: FACTORS
* 
* Description: This is the master do file for the analysis of DFID Education 
* for the FACTORS paper: "Faculty Choice Trends and Influences among Students in 
* Chitwan Valley, Nepal"
* 	
* For now I want to only check if there is some significant between only sciecne
* as a faculty vs Father's Occupation
*
* Author: Saujanya Wagle
*
* Created: 16/06/2024
*
* Last Modified:18/06/2024
* 
*-------------------------------------------------------------------------------

set more off

* set global project directoy
global 	project_dir 	"C:\Users\ISERN13\Desktop\factors2"
global 	raw_data 		"$project_dir\raw_data"
global 	clean_data 		"$project_dir\cleaned"




*======================start with 2018 Student DFID Data========================

use "$raw_data\2024StudentRestricted\StudentSurvey2024.dta", clear


* delete unnecessary variables based on the factors results
keep HHRID StdID StuGender ParnID SA_1 SA_2 SA_5_Faculty SA_9_Faculty SA_10 SA_13_Faculty 		///
SG_1_AB1 SG_1_AB1_Other SG_2_AB3 SG_2_AB3_Other SG_3_AB1 SG_3_AB1_Other SG_4_AB3_Other SG_4_AB3 Siwdate


* rename labels for easier understanding
la variable HHRID 		"Household ID"
la variable Siwdate 	"Student Survey 2023 Interview Date"
la variable SA_1		"Current Status - Studying / Finished Exam / Stopped Studying"
la variable SA_2		"If studying - Current Class" 



// Dependent Variable
*-------------------------------------------------------------------------------
* Question SA_10, asks when the student dropped. As we want only students after
* Grade 10, we should drop any students grade 10 and down

drop if SA_10 >= 9 & SA_10 < 11


* As Faculty is the dependent variable, we combine 3 variables which state Faculty 
gen Faculty = SA_5_Faculty
replace Faculty = SA_9_Faculty if Faculty == -1
replace Faculty = SA_13_Faculty if Faculty == -1

*Combine different faculty based on similar group
*** Management , Hotel Management  -> 1 (Management)
replace Faculty = 1 if Faculty == 3

*** Science, Agriculture / Veterinary, Computer Science, IT, Engineering, Medical, Forestry -> 2 (Sciences)
replace Faculty = 2 if Faculty == 5 | Faculty == 6 | Faculty == 7 | Faculty == 9 ///
 | Faculty == 10 | Faculty == 13
 
*** Education, Law, Humanities, Fashion design / Arts, Scriptures ->  3 Others (Humanities, Education, Arts)
replace Faculty = 3 if Faculty == 4 | Faculty == 8 | Faculty == 11 | 			///
Faculty == 12 | Faculty == 15

*** class 9, 10 -> 4 (Drop Maybe)
replace Faculty = 4 if  Faculty == 14 

*** Label Value
la define _faculty 1"Management" 2"Science" 3"Edu/Arts/Humanities" 4"Grade 9/10"
la value Faculty _faculty

*drop SA_5_Faculty SA_9_Faculty SA_13_Faculty 
la variable Faculty "Depended Variable - Which Faculty Choosen"

* Drop Faculty if not finished middle school
drop if Faculty == 4 
*-------------------------------------------------------------------------------



//Father's Occupation
*-------------------------------------------------------------------------------
gen Father_occu = SG_2_AB3

* replace others from others column (SG_2_AB3)
replace Father_occu = SG_2_AB3_Other if Father_occu == 97

*** Does not work, Housewife, Dont know, refused, Social worker, Dead, Other --> 0 (Doesn't Work)
replace Father_occu = 0 if Father_occu == 3 | Father_occu == 98 | ///
Father_occu == 99 | Father_occu == 23 | Father_occu == 24 | Father_occu == 97

*** Agriculture work - Own Land --> 1 Agriculture

*** Agriculture work - paid to work other's land, Construction Worker, Manufacturing, Cleaner, labor --> 2 Labor
replace Father_occu = 2 if  Father_occu == 2 | Father_occu == 4 | Father_occu == 7 ///
| Father_occu == 12 | Father_occu == 16 

*** Driver, Mechanic, Police/Security, Military, Teacher, Health Professional, 
*** Office Worker, Accountant, Industry operator, tourist guide/electrician/ 
*** musician/Creator/Artist, Barista/Cook/waiter  --> 3 Salary Job
replace Father_occu = 3 if Father_occu == 5 |Father_occu == 6 |Father_occu == 8 ///
|Father_occu == 9 |Father_occu == 10 |Father_occu == 11 |Father_occu == 14 		///
|Father_occu == 15 |Father_occu == 17 |Father_occu == 19 |Father_occu == 20|Father_occu == 22

*** Home Production, Business/Singer/Dancer/Player/Journalist
replace Father_occu = 4 if Father_occu == 13 | Father_occu == 18

la variable Father_occu "Father's Occupation"
la define _occu 0"Doesn't Work" 1"Agriculture" 2"Labor" 3"Salary Job" 4"Business"
la value Father_occu _occu
*-------------------------------------------------------------------------------



//Father's Education
*-------------------------------------------------------------------------------
gen Father_educ = SG_1_AB1

*** Never attended school, Other(Dead), Don't Know		-> 0 "Never Attended"
replace Father_educ = 0 if Father_educ == 1 |Father_educ == 97 |Father_educ == 98

*** Preschool to Grade 8
replace Father_educ = 1 if Father_educ > 1 & Father_educ <= 9

*** Grade 9 to Grade 12
replace Father_educ = 2 if Father_educ > 9 & Father_educ <= 13

*** Bachelor - Masters - PHD 
replace Father_educ = 3 if Father_educ > 13 & Father_educ <= 16

la variable Father_educ "Father's Highest level of Education"
la define _educ 0"Never Attended Formal Schooling" 1"PreSchool to Grade 8" 2"Grade 9 to Grade 12" 3"Above Grade 12"
la value Father_educ _educ
*-------------------------------------------------------------------------------



//Mother's Occupation
*-------------------------------------------------------------------------------
gen Mother_occu = SG_4_AB3

* replace others from others column (SG_2_AB3)
replace Mother_occu = SG_4_AB3_Other if Mother_occu == 97

*** Does not work, Housewife, Dont know, refused, Social worker, Dead, Other, , Inappropriate --> 0 (Doesn't Work)
replace Mother_occu = 0 if Mother_occu == 3 | Mother_occu == 98 | ///
Mother_occu == 99 | Mother_occu == 23 | Mother_occu == 24 | Mother_occu == 97 ///
| Mother_occu == -1

*** Agriculture work - Own Land --> 1 Agriculture

*** Agriculture work - paid to work other's land, Construction Worker, Manufacturing, Cleaner, labor --> 2 Labor
replace Mother_occu = 2 if  Mother_occu == 2 | Mother_occu == 4 | Mother_occu == 7 ///
| Mother_occu == 12 | Mother_occu == 16 

*** Driver, Mechanic, Police/Security, Military, Teacher, Health Professional, 
*** Office Worker, Accountant, Industry operator, tourist guide/electrician/ 
*** musician/Creator/Artist, Barista/Cook/waiter  --> 3 Salary Job
replace Mother_occu = 3 if Mother_occu == 5 | Mother_occu == 6 | Mother_occu == 8 ///
| Mother_occu == 9 | Mother_occu == 10 | Mother_occu == 11 | Mother_occu == 14 	///
| Mother_occu == 15 | Mother_occu == 17 | Mother_occu == 19 | Mother_occu == 20| Mother_occu == 22

*** Home Production, Business/Singer/Dancer/Player/Journalist
replace Mother_occu = 4 if Mother_occu == 13 | Mother_occu == 18

la variable Mother_occu "Mother's Occupation"
la value Mother_occu _occu
*-------------------------------------------------------------------------------



//Mothers's Education
*-------------------------------------------------------------------------------
gen Mother_educ = SG_3_AB1

*** Never attended school, Other(Dead), Don't Know		-> 0 "Never Attended"
replace Mother_educ = 0 if Mother_educ == 1 | Mother_educ == 97 | Mother_educ == 98

*** Preschool to Grade 8
replace Mother_educ = 1 if Mother_educ > 1 & Mother_educ <= 9

*** Grade 9 to Grade 12
replace Mother_educ = 2 if Mother_educ > 9 & Mother_educ <= 13

*** Bachelor - Masters - PHD 
replace Mother_educ = 3 if Mother_educ > 13 & Mother_educ <= 16

la variable Mother_educ "Mother's Highest level of Education"
la value Mother_educ _educ

save "$clean_data\stu_surv_2023_mod", replace
*-------------------------------------------------------------------------------




*========================== Clean 2018 Assist file ============================

* start with 2018 Student DFID Data
use "$raw_data\Restricted\StdAsst.dta", clear


* keep necessary variable
keep StdID_Asst BLE BL_Nepali BL_Math BL_Science 	///
Ethinicity HHID ParnID StdID Attendance SchlType

la variable SchlType "Private School or Public School"

destring StdID, replace
drop if StdID == -1

save "$clean_data\stu_assist_2018_mod", replace

*-------------------------------------------------------------------------------


*========================== Clean 2024 Parent Data =============================

use "$raw_data\2024ParentRestricted\ParentSurveyData2024.dta", clear

* keep necessary variable

keep StdID PA10_B_3
*PA_1_1 PA_1_2 PA_1_3 PA_1_4 PA_1_5 PA_1_6 PA_1_7 

destring StdID PA10_B_3, replace

rename PA10_B_3 Total_Income

save "$clean_data\par_survey_2024_mod", replace
*-------------------------------------------------------------------------------


*=================== Merge Student Assist & 2024 Parent Data ===================

* start with 2023 Student DFID Data
use "$clean_data\stu_surv_2023_mod", clear

merge 1:1 StdID using "$clean_data\stu_assist_2018_mod", force
drop if _merge == 2
drop _merge

merge 1:1 StdID using "$clean_data\par_survey_2024_mod", force
drop if _merge == 2
drop _merge

la define _eth 1"Brahmin/Chhetri" 2"Hill Janjati" 3"Dalit" 4"Newar" 			///
5"Terai Janjati" 6"Others"
la value Ethinicity _eth

la define _schtype 1"Community/Public" 2"Institutional/Private"
la value SchlType _schtype 


gen only_mgnt = (Faculty == 1)
gen only_sci = (Faculty == 2)
gen only_arts = (Faculty == 3)







/* 
keep StuGender Ethinicity SchlType Father_occu Father_educ Mother_occu Mother_educ Attendance Total_Income BLE Faculty


ssc install asdoc

cd "C:\Users\ISERN13\Desktop\factors2"

foreach var of varlist _all {
    asdoc tab `var', save(tab_file)
}



logit only_arts i.Father_educ

logit only_sci i.Father_educ, or

logit only_sci i.Father_occu

logit only_sci i.Father_occu, or

logit only_sci Ethinicity SchlType i.Father_occu




**** Add Income variable 

	 

*save "$clean_data\stu_surv_2023_mod", replace
