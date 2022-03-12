/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-11-730124633-Task4.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-11-15
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-11 task 4. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

libname echo '/folders/myfolders/BIOS-511-FALL-2018-master/data/echo';

%let outputPath=/folders/myfolders/BIOS-511/LAB-11;
%let task4FName=lab-11-730124633-Task-4-output;

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




%macro scatMat2(testcdList=, visitnum=, grp=);

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
		if visitnum = &visitnum. then call symput('week',strip(visit));
		
		
		
		if last=1 then
			do;
				call symput('lab',strip(vstest));
				call symput('unit',strip(vsstresu));
 			end;

		drop vstestcd vsstresu vsseq vsblfl vsstat vsreasnd studyid;
		rename vsstresn = &testcd.;
	run;
		
	data &testcd.; 
		set &testcd.;
		label &testcd. = "&lab. (&unit.)";
	run;
	
	%let sets&i=&testcd.;
	
%end;

%* Create vs_horiz;

	

data vs_horiz;
	merge 
		%do n=1 %to &testnum; &&sets&n %end;;
	by usubjid visitnum visit;
run;

ods graphics / height=7in width=7in;


title1 "Scatter Plot Matrix for &testcdList";
title2 "Visit = &week";
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



ods pdf file="&outputPath./&task4FName..pdf" style=journal;

ods graphics / height=7.25in width=7in;

%scatMat2(testcdList=DIABP|SYSBP|WEIGHT,visitnum=1);

ods pdf close;













