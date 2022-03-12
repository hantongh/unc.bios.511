/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-09-730124633-Task1.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-11-03
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-09 Task 1. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

libname echo '/folders/myfolders/BIOS-511-FALL-2018-master/data/echo';
libname lab9 '/folders/myfolders/BIOS-511/LAB-09';

data work.lb;
	set lab9.lb;
run;

data work.dm;
	set echo.dm;
run;

/* Merge DM dataset to LB dataset, add var: age, sex, race, country, 
	armcd, arm */

proc sort data=lb;
	by usubjid;
run;

proc sort data=dm;
	by usubjid;
run;

data adlb_dmlb;
	merge lb dm;
	by usubjid;
	drop RFXENDTC RFICDTC AGEU DMDTC;
run;


/* Add variable */

proc sort data=adlb_dmlb;
	by USUBJID LBTESTCD LBTEST VISITNUM VISIT LBDTC;
run;

data adlb_seqcat;
	set adlb_dmlb;
	by USUBJID LBTESTCD LBTEST VISITNUM VISIT LBDTC;
	
* Add variable LBSEQ;

	length LBSEQ 8;
	label LBSEQ='Sequence Number';
	
	if count=. then 
		do;
			count=0;
		end;
	
	lbseq=count+1;
	
	if LAST.usubjid=0 then count+1;
	else if LAST.usubjid=1 then count=0;
	
	drop count;
	
* Add variable LBNRIND;

	length LBNRIND $5;
	label LBNRIND='Reference Range Indicator';
	
	if LBTESTCD='ALB' then
		do;
			if LBSTRESN=. then LBNRIND='';
			else do;
				if LBSTRESN<35 then LBNRIND='L';
				else if 35<=LBSTRESN<=55 then LBNRIND='N';
				else if LBSTRESN>55 then LBNRIND='H';
			end;
		end;
	else if LBTESTCD='CA' then
		do;
			if LBSTRESN=. then LBNRIND='';
			else do;
				if LBSTRESN<2.1 then LBNRIND='L';
				else if 2.1<=LBSTRESN<=2.7 then LBNRIND='N';
				else if LBSTRESN>2.7 then LBNRIND='H';
			end;
		end;
	else if LBTESTCD='HCT' then
		do;
			if LBSTRESN=. then LBNRIND='';
			else do;
				if sex='M' then
					do;
					if LBSTRESN<0.388 then LBNRIND='L';
					else if 0.388<=LBSTRESN<=0.5 then LBNRIND='N';
					else if LBSTRESN>0.5 then LBNRIND='H';
				end;
				if sex='F' then
					do;
					if LBSTRESN<0.349 then LBNRIND='L';
					else if 0.349<=LBSTRESN<=0.445 then LBNRIND='N';
					else if LBSTRESN>0.445 then LBNRIND='H';
				end;
			end;
		end;
run;


/* Add variable LBBLFL */

proc sort data=adlb_seqcat out=adlb_fl;
	by usubjid lbtestcd;
run;

data lbblfl_select;
	set adlb_fl;
	
	by usubjid lbtestcd;
	
	length LBBLFL $1;
	label LBBLFL='Baseline Flag';
	
	lbdtcn=input(substr(lbdtc,1,10),yymmdd10.);
	RFXSTDTCN=input(RFXSTDTC,yymmdd10.);
	
	if LBSTRESN~=.;
	
	if LBDTCN<=RFXSTDTCN;
	
	keep usubjid lbtestcd visit LBBLFL;

run;

data lbblfl;
	set lbblfl_select;
	by usubjid lbtestcd;
	
	if last.lbtestcd=1 then LBBLFL='Y';
	
	
run;

data adlb_lbblfl;
	merge adlb_seqcat lbblfl;
	by usubjid lbtestcd visit;
	
	drop RFXSTDTC;
run;


* Add variable BASE BASECAT CHANGE PCT_CHANGE;	

data adlb_base;

	set adlb_lbblfl;
	
	length BASE 8 BASECAT $1
			CHANGE PCT_CHANGE 8;
	label base='Baseline Lab Test Value'
			basecat='Baseline Reference Range Indicator'
			change='Change from Baseline'
			pct_change='Percent Change from Baseline';
	
	if lbblfl='Y' then
	do;
		base=LBSTRESN;
		basecat=LBNRIND;
	end;
	
run;

proc sort data=adlb_base;
	by usubjid lbtestcd descending base;
run;

data adlb_base;
	set adlb_base;
	by usubjid lbtestcd;
	
	retain temp tempn;
	
	if first.lbtestcd=1 and base~=. then do;
		temp=base;
		tempn=basecat;
	end;
	else if first.lbtestcd=1 and base=. then do;
		temp=.;
		tempn='';
	end;
	else do;
		base=temp;
		basecat=tempn;
	end;
	
	change=LBSTRESN-BASE;
	pct_change=(LBSTRESN-BASE)/BASE*100;

	drop temp tempn;

run;
	
proc sort data=adlb_base out=adlb;
	by usubjid lbtestcd visit;
run;

data lab9.ADLB;
	set adlb;
run;

/*
proc print data=adlb;
	where usubjid='ECHO-011-003';
run;

proc contents data=adlb order=varnum;
run;
*/


/* End of Lab 09 Task 1 */


