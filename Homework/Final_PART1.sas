/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : PART1-730124633.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-12-09
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 Final exam Part 1. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

%let root        = /folders/myfolders/BIOS-511/FINAL;
%let analysisDat = &root./analysis_data;
%let qualDat = &root./qualtrics_data;
%let macro = &root./macros;
%let outputPath = &root./output;

libname raw "&qualDat." access=read;
libname analysis "&analysisDat.";


* Step 1: Import first two lines of data set and transpose to create qstest;
proc import datafile="&qualDat./sis16.csv" out=adsis_raw dbms=csv replace;
	getnames=yes;
run;

data _label_;
	set adsis_raw;
	if responseid='Response ID';
	
	q17='Stroke Impact Scale 16 Score';
run;

proc transpose data=_label_ out=qstest;
	var q:;
run;

* Step 2: Import observation data;
proc import datafile="&qualDat./sis16.csv" out=adsis_raw1 dbms=csv replace;
	getnames=yes;
	datarow=3;
	* All variables numeric;
run;

* Add variable USUBJID, calculate AVAL for #17, var named Q17;
data adsis_raw1;
	set adsis_raw1;
	
	USUBJID=put(responseid,z4.);
	
	nMiss = nmiss(of q1-q16);

	format q17 6.2;
	if nMiss<3 then do;
		q17=put((sum(of q1-q16)-(16-nmiss))/(4*(16-nmiss))*100,6.2);
	end;
	else do;
		q17=.;
		ndone=16-nmiss;
	end;
	
	drop responseid;
run;

proc sort data=adsis_raw1;
	by USUBJID;
run;

proc transpose data=adsis_raw1 out=adsis_trans;
	by USUBJID ndone;
	var q:;
run;

proc sql;
	create table adsis_join as
	select t.USUBJID,t._name_,t.col1 as AVAL,t.ndone,q.col1 as ques
		from adsis_trans as t
			inner join
			qstest as q
			on t._name_=q._name_;
quit;

data adsis;
	retain USUBJID;
	length QSSEQ 8 QSTESTCD $10 QSTEST $200 QSTYP $10 AVALC $20;
	retain AVAL; format AVAL best5.2;
	length QSSTAT QSREASND $50;
	
	label USUBJID='Unique Subject ID'
			QSSEQ='Item Sequence Number'
			QSTESTCD='Survey Item Code'
			QSTEST='Survey Item'
			QSTYP='Survey Item Type'
			AVALC='Analysis Value (Character)'
			AVAL='Analysis Value'
			QSSTAT='SIS-16 Score Status'
			QSREASND='Reason SIS-16 Score Not Calculated';
	
	set adsis_join;
	
	qstest=ques;
	qsseq=input(substr(_name_,2),8.);
	
	qstestcd=cats('ITEM',put(qsseq,z2.));
	if qsseq=17 then do;
		qstestcd='SIS16';
		qstyp='DERIVED';
	end;
	
	if aval=1 then AVALC='Could not do at all';
	else if aval=2 then AVALC='Very difficult';
	else if aval=3 then AVALC='Somewhat difficult';
	else if aval=4 then AVALC='A little difficult';
	else if aval=5 then AVALC='Not difficult at all';
	else if aval<>. then AVALC=strip(aval);
	
	
	if qsseq=17 and aval=. then do;
		QSSTAT='NOT CALCULATED';
		QSREASND=catx(' ','Only',ndone,'Items Answered');
	end;
	
	drop _name_ ndone ques;
run;

proc sort data=adsis out=analysis.ADSIS;
	by USUBJID QSSEQ;
run;

