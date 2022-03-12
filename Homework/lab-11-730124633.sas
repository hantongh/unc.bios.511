/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-11-730124633.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-11-15
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-11. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

libname echo '/folders/myfolders/BIOS-511-FALL-2018-master/data/echo';

%let outputPath=/folders/myfolders/BIOS-511/LAB-11;
%let task2FName=lab-11-730124633-Task-2-output;
%let task3FName=lab-11-730124633-Task-3-output;

/*********************************************************************
 	SAS Code for Task # 1
*********************************************************************/


proc sort data=echo.vs out=vs_sorted;
	by usubjid;
run;

proc sort data=echo.dm out=dm_sorted(keep=usubjid armcd);
	by usubjid;
run;

* Merging datasets dm and vs, dm armcd into vs;
data vs;
	merge vs_sorted dm_sorted;
	by usubjid;
	
	* Revise length of vstestcd for further use;
	length vstestcd_revised $40;
	vstestcd_revised=vstestcd;
	
	drop vstestcd;
	rename vstestcd_revised=vstestcd;

run;



/*********************************************************************
 	SAS Code for Task # 2
*********************************************************************/

%macro tst(testcd=);

data &testcd.;
	set vs end=last; %* creates a temporary numeric variable called last, 
						which is initialized to 0 and set to 1 when the SET 
						statement reads the last observation in the input data set;
						
	%* Set input values to upper case in order to compare with the values of vstestcd;
	where vstestcd="%upcase(&testcd.)";
	
	vstestcd=tranwrd(vstest,'Blood Pressure','BP');
	
	%* When reaching the last observation, execute the CALL SYMPUT routine;
	if last=1 then
		do;
			%* create macro variable LAB that is assigned 
				with value vstest (of this observation);
			call symput('lab', strip(vstestcd));
			%* create macro variable UNIT that is assigned 
				with value vsstresu (of this observation);
			call symput('unit', strip(vsstresu));
		end;
		
	drop  vstestcd vstest vsstresu vsseq vsblfl vsstat vsreasnd studyid;
	
	%* rename variable vsstresn with parameter we input when using this macro;
	rename vsstresn = &testcd.;
	
run;

%* Show the value of macro var lab and unit in the log;
%put LAB=&lab. UNIT=&unit.;

data &testcd.;
	set &testcd.;
	
	%* label the vsstresn with the value of 
	macro variable lab (originally value of vstestcd)
	and unit (originally value of vsstresu);
	label &testcd. = "&lab. (&unit.)";
run;
%mend;


* create datasets diabp, sysbp, and hr by using the macro tst;
%tst(testcd=diabp);
%tst(testcd=sysbp);
%tst(testcd=hr);

data vs_horiz;
	merge diabp sysbp hr;
	by usubjid visitnum visit;
run;

* ..after task2FName: first . indicates the end of the macro variable task2FName and shows
	there are things after this variable, second . is meaningful with pdf and forms
	the output format of this file (.pdf));
ods pdf file="&outputPath./&task2FName..pdf" style=journal;

ods graphics / height=7.25in width=7in;
 title1 "Scatter Plot Matrix for Distolic BP, Systolic BP, and Heart Rate";
 title2 "Visit = Week 32";

proc sgscatter data = vs_horiz;
	where visitnum = 5;
	matrix diabp sysbp hr / diagonal=(histogram) group=armcd;
run;

ods graphics / reset=all;

ods pdf close;



/*********************************************************************
 	SAS Code for Task # 3
*********************************************************************/

%macro scatMat(testcdList=, visitnum=, grp=);

%* To use a sas function in macro, need to use sysfunc();
%* Note that arguments are NOT quoted as they would be when using the DATA step function COUNTW;
%let testnum= %sysfunc(countw(&testcdList.,|));

%* loop over the number of tests to include;
%do i = 1 %to &testNum;

	%* Define testcd as the i-th element of the testcdList input;
	%* Note that arguments are NOT quoted as they would be when using 
		the DATA step function SCAN;
	%let testcd = %scan(&testcdList.,&i,|);

	data &testcd.;
		set vs end=last;
		where vstestcd = "%upcase(&testcd.)";

		vstest = tranwrd(vstest,'Blood Pressure','BP');

		if last=1 then
			do;
				call symput('lab',strip(vstest));
				call symput('unit',strip(vsstresu));
 			end;

		drop vstestcd vstest vsstresu vsseq vsblfl vsstat vsreasnd studyid;
	
		rename vsstresn = &testcd.;
	run;

	data &testcd.; 
		set &testcd.;
		label &testcd. = "&lab. (&unit.)";
	run;

	%* Need to compare different categories in testcdList, but no need to compare
		one category with itself;
 	%if &i = 1 %then
 		%do;
 			data vs_horiz;
 				set &testcd.;
 				by usubjid visitnum visit;
 			run;
 		%end;
 	%else
 		%do;
 			data vs_horiz;
 				merge vs_horiz &testcd.;
 				by usubjid visitnum visit;
 			run;
 		%end;
 		
%end;


ods graphics / height=7in width=7in;

proc sgscatter data = vs_horiz;
	where visitnum = &visitnum.;
	matrix %sysfunc(tranwrd(&testcdList.,|, )) /
 	%if &grp^= %then
 		%do;
 			group=&grp.
 		%end;
 	diagonal=(histogram);
run;

%mend;


ods pdf file="&outputPath./&task3FName..pdf" style=journal;

ods graphics / height=7.25in width=7in;
title1 "Scatter Plot Matrix for Distolic BP, Systolic BP, and Weight";
title2 "Visit = Week 0";

%scatMat(testcdList=DIABP|SYSBP|WEIGHT,visitnum=1);

ods pdf close;

