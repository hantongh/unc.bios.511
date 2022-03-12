ods html file='/folders/myfolders/BIOS-511/LAB-03/lab-03-730124633-output.html';

libname lab3 "/folders/myfolders/BIOS-511/LAB-03";

/*********************************************************************
 	SAS Code for Task # 1
*********************************************************************/

data dm_task1;
	set lab3.dm_invnam;
	length agecat $5;
	if age=. then agecat='';
	else if age<65 then agecat='<65';
	else agecat='>=65';
	if age=. then agecatn=99;
	else agecatn=1+(age>=65);
run;

/*proc freq data=dm_task1;
	table age*agecatn*ageCat / list missing nocum nopercent;
run; */

ods noproctitle;

title1 'Task 1 / Step 4: Two-Way Frequency Analysis of Treatment Group by Age Category';
proc format;
	value $armcd_form
		'ECHOMAX'='Intervention'
		'PLACEBO'='Placebo';
run;

ods select CrossTabFreqs Chisq;
proc freq data=dm_task1;
	table agecat*armcd/ chisq norow nopercent;
	label agecat='Age Category' armcd='Treatment Group';
	format armcd $armcd_form.;
run;

title;

/*********************************************************************
 	SAS Code for Task # 2
*********************************************************************/

proc sort data=lab3.dm_invnam 
			out=investigators1(keep=country siteid invnam) nodupkey;
	by siteid invnam;
run;
	
data investigators2;
	set investigators1;
	length firstname lastname $30 country_long $10;
	label lastname='Investigator Last Name'
			firstname='Investigator First Name'
			country_long='Country Name';
	
	lastname=strip(propcase(scan(invnam,1,',')));
	firstname=strip(propcase(scan(invnam,2,',')));
	
	if country='USA' then 
		do;
			country_order=1;
			country_long='USA';
		end;
	else if country='MEX' then 
		do;
			country_order=2;
			country_long='Mexico';
		end;
	else do;
		country_order=3;
		country_long='Canada';
		end;
run;

proc sort data = investigators2;
	by country_order country_long;
run;

title1 "Task 2 / Step 4: Listing of ECHO Trial Investigators";
title2 "Country = #byval(COUNTRY_LONG)";
options nobyline;
proc print data=investigators2 noobs label;
	by country_order country_long;
	
	var siteid lastname firstname;
run;

title;

/*********************************************************************
 	SAS Code for Task # 3
*********************************************************************/

data dm_task3;
	set lab3.dm_invnam;
	length firstname lastname $30 
			icyear icmonth icday $5
			RFICDTC3 RFICDTC4 RFICDTC5 $20
			racecat $30;
	
	comma_spot=index(invnam,',');
	lastname=propcase(substr(invnam,1,comma_spot-1));
	firstname=propcase(substr(invnam,comma_spot+1));
	
	icyear=scan(RFICDTC,1);
	icmonth=scan(RFICDTC,2);
	icday=scan(RFICDTC,3);
	
	RFICDTC3=strip(icyear) || '-' || strip(icmonth) || '-' || strip(icday);
	RFICDTC4=cats(icyear,'-', icmonth,'-', icday);
	RFICDTC5=catx('-',icyear,icmonth,icday);
	
/*	if race='WHITE' then racecat='White';
	else if race='BLACK OR AFRICAN AMERICAN' then racecat='Black or African American';
	else racecat='Other'; */
	
	racecat=tranwrd(propcase(race),'Or','or');
	if racecat~='White' and racecat~='Black or African American'
		then racecat='Other';
		
	drop comma_spot;
run;

title 'Task 3 / Step 2: Print Out of Derived Variables for Site 011';
proc print data=dm_task3 (obs=10) noobs;
	where siteid='011';
	var invnam firstname lastname
		rficdtc icyear icmonth icday RFICDTC3 RFICDTC4 RFICDTC5
		race racecat;
run;



ods html close;