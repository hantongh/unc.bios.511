/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-06-730124633.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-10-02
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-06. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

libname lab6 "/folders/myfolders/BIOS-511/LAB-06";


/*********************************************************************
 	SAS Code for Task # 1
*********************************************************************/

/*
proc contents data=lab6.vs;
run;
*/

proc print data=lab6.vs;
	where USUBJID='ECHO-011-001';
run;


/*********************************************************************
 	SAS Code for Task # 2
*********************************************************************/

/* Approach 1: Creating multiple datasets and merging them. */

proc sort data = lab6.vs out=work.vs1;
	by usubjid visitnum visit vstestcd;
run;

data WORK.DIABP;
	set work.vs1;
	where VSTESTCD='DIABP';
	rename VSSTRESN=DIABP;
run;

/*proc sort data = WORK.DIABP;
	by visit;
run;*/

data WORK.SYSBP;
	set work.vs1;
	where VSTESTCD='SYSBP';
	rename VSSTRESN=SYSBP;
run;

/*proc sort data = WORK.SYSBP;
	by visit;
run;*/


data WORK.BP1;
	merge work.diabp work.sysbp;
	by usubjid visitnum visit;
	keep usubjid visitnum visit sysbp diabp;
run;

/*proc print data=work.bp1 noobs;
	where USUBJID='ECHO-011-001';
	var usubjid visitnum visit diabp sysbp;
run;*/


/* Approach 2: Using arrays and conditional output 
		statements/subsetting IF statements. */
	
proc sort data = lab6.vs out = work.VS;
	by usubjid visitnum visit vstestcd;
	where vstestcd='DIABP' or vstestcd='SYSBP';
run;

/*option ls=150;
data _null_;
set work.VS(obs=20);
by usubjid visitnum visit vstestcd;
putlog _n_= usubjid= first.usubjid= last.usubjid=
 visitnum= visit= first.visit= last.visit= vstestcd= ;
run;*/

data BP2;
	set work.VS;
	by usubjid visitnum visit vstestcd;
	retain sysbp diabp;
	
	if first.visit then do;
 		sysbp = .;
 		diabp = .;
	end;
	
	if vstestcd = 'SYSBP' then sysbp = vsstresn;
	if vstestcd = 'DIABP' then diabp = vsstresn;
	
	if last.visit;
	keep usubjid visitnum visit sysbp diabp;
run;

/*proc print data=bp2;
	where USUBJID='ECHO-011-001';
	var usubjid visitnum visit sysbp diabp;
run;*/


/* Approach 3: Using PROC TRANSPOSE */

proc sort data = lab6.vs out = VS3;
	by usubjid visitnum visit vstestcd;
run;

proc transpose data = VS3
 		out = BP3 (drop=_name_ _label_);
	by usubjid visitnum visit;
	where vstestcd='DIABP' or vstestcd='SYSBP';
	id vstestcd;
	idlabel vstest;
	var vsstresn;
run;

/*proc print data=bp3;
	where USUBJID='ECHO-011-001';
run;*/


/*********************************************************************
 	SAS Code for Task # 3
*********************************************************************/

data work.vs;
	set lab6.vs;
	where vstestcd in ('DIABP' 'SYSBP');
run;

proc sort data = work.vs;
	by usubjid visitnum visit vstestcd;
run;

data lab6.BP4;
	set work.vs;
	by usubjid visitnum visit vstestcd;
	retain DBP_SCR DBP_WK00 DBP_WK08 DBP_WK16 DBP_WK24 DBP_WK32
		   SBP_SCR SBP_WK00 SBP_WK08 SBP_WK16 SBP_WK24 SBP_WK32;
	array bp[2,6] DBP_SCR DBP_WK00 DBP_WK08 DBP_WK16 DBP_WK24 DBP_WK32
 				  SBP_SCR SBP_WK00 SBP_WK08 SBP_WK16 SBP_WK24 SBP_WK32;
	
	if first.usubjid then do;
		dbp_scr=.; dbp_wk00=.; dbp_wk08=.; dbp_wk16=.; dbp_wk24=.; dbp_wk32=.;
		sbp_scr=.; sbp_wk00=.; sbp_wk08=.; sbp_wk16=.; sbp_wk24=.; sbp_wk32=.;
	end;
	
	if vstestcd = 'DIABP' then array_row = 1;
	else if vstestcd = 'SYSBP' then array_row = 2;
	
	if visit = 'Screening' then array_col = 1;
	else if visit = 'Week 0' then array_col = 2;
	else if visit = 'Week 8' then array_col = 3;
	else if visit = 'Week 16' then array_col = 4;
	else if visit = 'Week 24' then array_col = 5;
	else if visit = 'Week 32' then array_col = 6;
	
 	bp[array_row,array_col] = vsstresn;
 	
 	if last.usubjid;
 	
	keep usubjid visitnum visit dbp: sbp:;
run;

/*
proc compare base=lab6.bp4 compare=lab6.bp4_s;
run;

proc print data=lab6.bp4;
	where USUBJID='ECHO-011-001';
run;
*/


/*********************************************************************
 	SAS Code for Task # 4
*********************************************************************/

data BP5;
	set lab6.VS;
	where vstestcd in ('DIABP' 'SYSBP');
	length varName $20.;

	if vstestcd='DIABP' then varName='DBP_';
	else varName='SBP_';
	
	
	if visit='Screening' then varName=cats(varName,'SCR');
	else if visit = 'Week 0' then varName=cats(varName,'WK00');
	else if visit = 'Week 8' then varName=cats(varName,'WK08');
	else if visit = 'Week 16' then varName=cats(varName,'WK16');
	else if visit = 'Week 24' then varName=cats(varName,'WK24');
	else if visit = 'Week 32' then varName=cats(varName,'WK32');

run; 

proc sort data=bp5;
	by usubjid visitnum visit vstestcd; 
run;

proc transpose data=bp5 out=lab6.bp5 (drop=_name_ _label_);
	by usubjid;
	id varName;
	var vsstresn;
run;

/*
proc compare base=lab6.bp5 compare=lab6.bp5_s;
run;

proc print data=lab6.bp5;
	where USUBJID='ECHO-011-001';
run;
*/








