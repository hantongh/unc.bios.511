/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-05-730124633.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-09-25
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-05. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

ods html file='/folders/myfolders/BIOS-511/LAB-05/lab-05-730124633-output.html';

libname echo "/folders/myfolders/BIOS-511-FALL-2018-master/data/echo";

ods noproctitle;



/*********************************************************************
 	SAS Code for Task # 1
*********************************************************************/

proc format;
	value AGECAT
		low-49='1: <50'
		50-64='2: 50 to <65'
		65-high='3: >=65'
		other='4: Missing';
run;

data work.dm1;
	set echo.dm;
	format age AGECAT.;
	AGECATEGORY=put(age,AGECAT.);
	label agecategory='Age Category';
run;

/*proc contents data=work.dm1;
run;*/

title1 'Task 1 / Step 3: One-Way Analysis of Age Categories (Using Formatted AGE Variable)';

proc freq data=work.dm1;
	label age='Age Category';
	table age;
run;
title;

title1 'Task 1 / Step 4: One-Way Analysis of Age Categories (Using AGECATEGORY Variable)';

proc freq data=work.dm1;
	table agecategory;
run;
title;

/*********************************************************************
 	SAS Code for Task # 2
*********************************************************************/

proc format;
	invalue sexn
		"M" = 1
		"F" = 2
		OTHER = .;
run;

data work.dm2;
	set work.dm1;
	length trtdur 4;
	sexnum=input(sex,sexn.);
	trtstdtn = input(rfxstdtc,yymmdd10.);
	trtendtn = input(rfxendtc,yymmdd10.);
	trtdur=(1+trtendtn-trtstdtn)/7;
	format trtstdtn trtendtn date9.;
run;

proc means data=work.dm2 n mean stddev min max nonobs maxdec=4 noprint;
	class agecategory armcd;
	ways 1;
	var trtdur;
	output out=WORK.TRTDUR_SUMMARY n=n mean=mean stddev=std min=min max=max;
run;

title1 'Task 2 / Part 5: Summary of Treatment Duration by Treatment Group';
proc print data=work.trtdur_summary noobs label split=' ';
	where agecategory='';
	var armcd n mean std min max;
	format mean min max 6.2
			std 7.3;
	label armcd='Treatment Group'
			n='Sample Size'
			mean='Mean'
			std='Standard Deviation'
			min='Minimum'
			max='Maximum';
run;
title;

title1 'Task 2 / Part 5: Summary of Treatment Duration by Age Category';
proc print data=work.trtdur_summary noobs label split=' ';
	where armcd='';
	var agecategory n mean std min max;
	format mean min max 6.2
			std 7.3;
	label armcd='Treatment Group'
			n='Sample Size'
			mean='Mean'
			std='Standard Deviation'
			min='Minimum'
			max='Maximum';
run;
title;




ods html close;