/*
Creator: Ethan Witkowski
Swarthmore Public Safety Staffing Audit
Swarthmore College Fall 2018
*/
clear
cd "C:\Users\ethan\Desktop\Swarthmore\Fall 2018\Econometics I\Project\Final Deliverables"
capture log close
log using quantAnalysis20.log, replace

use PublicSafetydata.dta

//PublicSafetydata.dta is sorted in chronological order

//drops duplicate events

local drop concurrent
duplicates drop

//Code below calculates the annual savings Public Safety can expect
//by cutting excess Building/Outdoor Area Checks

//Creates dummy variable (Check) if Incident is Building/Outdoor Area Check
//over the period Jan 2014-Nov 2018 

gen byte Check=1 if Incident == "BUILDING CHECK" | Incident == "OUTDOOR AREA CHECK"

//Displays number of actions taken by Public Safety over period of study
tabulate Incident
	return list
	gen action = r(N)
	di action
	
//Displays number of actions taken at night by Public Safety over period of study
tabulate Incident if hours >= 21 | hours <= 2
	return list
	gen nightaction = r(N)
	di nightaction

//Displays number of actions at night that were Building/Outdoor Area Checks
sum Check if hours >= 21 | hours <= 2
	return list
	gen nightCheck = r(N)
	di nightCheck
	
//Displays number of actions taken at night by Public Safety that weren't 
//Building/Outdoor Area Checks 
gen nightNonCheck = nightaction - nightCheck
di nightNonCheck

//Assumption 1: Patrol Officers perform Checks because they are waiting to be 
//called to perform an action

//Assumption 2: Public Safety will always want one patrol officer performing a Check so they
//will be able to respond to a call or emergency 

//The code below creates a variable (ExcessChecksnight) that is the excess number
//of Building/Outdoor Area Checks Public Safety performed at night above the number of
//actions that they were called to perform

gen ExcessChecksnight = nightCheck - nightNonCheck
di ExcessChecksnight

//Assumes each Building/Outdoor Area Check takes 10 minutes to resolve
//Assumes each Patrol Officer is paid $15.40/hr (PatrolHourlyWage)
//Creates variable (CostperCheck) that equals Public Saftey's cost per 
//Building/Outdoor Area Check
	
gen TimePerCheck = 10/60
gen PatrolHourlyWage = 15.40
gen CostperCheck = TimePerCheck*PatrolHourlyWage
di CostperCheck

//Creates new variable (costsavings) that equals the amount of costs Public
//Safety could save (in dollars) if they omitted the excess number of 
//Building/Outdoor Area Checks at night

gen costsavings = ExcessChecksnight * CostperCheck
di costsavings

//Number of days from Jan 01,2014 to Nov 15,2018 equals 1779
//Converts number of nights to years

gen days = 1779
di days
gen years = days/365
di years

//Generates variable yearlycostsavings that is the annual cost savings
//Public Safety can expect without excess checks

gen yearlycostsavings = costsavings/years
di yearlycostsavings





//Code below calculates the amount of checks that led to actions


//Creates dummy variable (CheckThenNonCheck) if the action that comes after a 
//Building/Outdoor Area Check is NOT a Building/Outdoor Area Check

gen byte CheckThenNonCheck = 1 if  Check == 1 &  Check[_n+1] == .

//Creates a variable (LocationValue) that encodes the string Variable "Location"
//as a numerical value

encode Location, generate(LocationValue)

//Generates a variable (SameLocation) if the Location after an observation
//is the same as the observation

gen byte SameLocation = 1 if LocationValue == LocationValue[_n+1]

//Creates variable (CheckLeadsNonCheck) if an observation following a 
//Building/Outdoor Area Check is in the same location and is not a Building Check

gen byte CheckLeadsNonCheck = 1 if CheckThenNonCheck == 1 & SameLocation == 1

//Displays the approximate number of Building Checks that led to actions 
//being taken at night (between 9pm and 3am)

summarize CheckLeadsNonCheck if hours >= 21 | hours <= 2
	return list
	gen NightCheckLeadsNonCheck = r(N)
	di NightCheckLeadsNonCheck

//Displays the percentage of Building Checks that led to actions being taken 
//at night 

gen PercentNightCheckLeadsNonCheck = NightCheckLeadsNonCheck/nightaction
di PercentNightCheckLeadsNonCheck

//Approximately 1.14% of Building Checks led to actions





//Code below is used to show difference in average Checks during night vs day


//Creates variable (avgnightCheck) that equals avg # of Building/Outdoor Area Checks
//each night over the period

gen avgnightCheck = nightCheck/days
di avgnightCheck

//Creates variable (avgnightCheckhr) that equals the # of Building/Outdoor Area Checks
//at night per hour 

gen avgnightCheckhr = avgnightCheck/6
di avgnightCheckhr

//Finds Building/Outdoor Area Checks/hr for whole day (same process as above)

sum Check
	return list
	gen wholeCheck = r(N)
	di wholeCheck

gen avgwholeCheck = wholeCheck/days
di avgwholeCheck

gen avgwholeCheckhr = avgwholeCheck/24
di avgwholeCheckhr

//Creates new variable (diffavgCheckhr) that equals the difference between
//the average amount of Building/Outdoor Area Checks/hr from 9pm-2am and 
//the whole day

gen diffavgCheckhr = avgnightCheckhr - avgwholeCheckhr
di diffavgCheckhr


log close

