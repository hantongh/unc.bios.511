/*****************************************************************************
* Project           : BIOS 511 Midterm
*
* Program name      : S730124633-PART-1.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-10-14
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 Midterm Part 1. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 2018-10-14      HH              
*
******************************************************************************/

ods pdf file='/folders/myfolders/BIOS-511/MIDTERM/S730124633-PART-1.pdf';

libname midterm "/folders/myfolders/BIOS-511/MIDTERM";

ods noproctitle;

/*********************************************************************
 	SAS Code for Q1, Q2, Q3
*********************************************************************/

title 'Q1-3: Treatment/Country group percentage and Consent year percentage';
data work.dm;
	set midterm.dm;
	length consent_year 4;
	label consent_year='Year Consented to Participate';
	consent_year=substr(rficdtc,1,4);
	drop studyid ageu race arm visitnum visit dmdtc;
run;

proc sort data=dm;
	by armcd consent_year;
run;

proc freq data=dm;
	table armcd*country/norow;
	table consent_year/nocum;
run;

title;


/*********************************************************************
 	SAS Code for Q4
*********************************************************************/

title 'Q4: Median age in the placebo group';

proc means data=dm n mean median maxdec=2;
	where armcd='PLACEBO';
	var age;
run;
title;

/*********************************************************************
 	SAS Code for Q5
*********************************************************************/

title 'Q5: Percentage of Age<65 and sex';

data dm_age;
	set dm;
	label young='Age<65?';
	if age<65 then young=1;
	else young=0;
run;

proc sort data=dm_age;
	by young;
run;

proc freq data=dm_age;
	table sex*young/nocol norow;
run;

title;



/*********************************************************************
 	SAS Code for Q6
*********************************************************************/

title 'Q6: Mean treatment duration in the ECHOMAX treatment group in months';

data dm_month;
	set dm;
	where armcd='ECHOMAX';
	date_end=input(RFXENDTC,yymmdd10.);
	date_start=input(RFXSTDTC,yymmdd10.);
	month_treat=(date_end-date_start+1)/30.4;
	format month_treat 8.2;
	drop date_end date_start;
run;

proc means data=dm_month n mean maxdec=2;
	var month_treat;
run;

title;

/*********************************************************************
 	SAS Code for Q7
*********************************************************************/

title 'Q7: Age group and sex distribution';
proc sort data=dm out=dm_sex;
	by sex;
run;

proc means data=dm_sex noprint;
	by sex;
	var age;
	output out=sex (drop=_type_ _freq_) q1=LowerQuad q3=UpperQuad;
run;

data dm_quad;
	merge dm_sex sex;
	by sex;
	
	length ageCategory $13;
	
	if sex='F' then
		do;
		if age<LowerQuad then ageCategory='Female-Low';
		else if LowerQuad<=age and age<=UpperQuad then ageCategory='Female-Median';
		else if age>UpperQuad then ageCategory='Female-High';
		else ageCategory='';
		end;
	else if sex='M' then
		do;
		if age<LowerQuad then ageCategory='Male-Low';
		else if LowerQuad<=age and age<=UpperQuad then ageCategory='Male-Median';
		else if age>UpperQuad then ageCategory='Male-High';
		else ageCategory='';
		end;
run;

proc freq data=dm_quad;
	table ageCategory/nocum;
run;

title;

ods pdf close;