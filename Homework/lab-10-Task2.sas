/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-10-730124633-Task2.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-11-11
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-10 Task 2. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

libname echo '/folders/myfolders/BIOS-511-FALL-2018-master/data/echo';
libname lab10 '/folders/myfolders/BIOS-511/LAB-10';

proc sort data=lab10.pc out=work.pc;
	by usubjid;
run;

proc sort data=echo.dm out=dm(keep=usubjid sex);
	by usubjid;
run;

data pc_sum;
	merge pc dm;
	by usubjid;
	
	if studyid='' then delete;
	
	format hours 5.2;
	hours=scan(PCTPT,1,' ');
	
	if PCSTRESC='<0.01' then PCSTRESN=0.01;
	
	length sexcat $8;
	if sex='M' then sexcat='Male';
	else if sex='F' then sexcat='Female';
	output;
	
	sexcat='Overall';
	output;
run;

proc sort data=pc_sum;
	by sexcat hours;
run;

proc means data=pc_sum nway noprint;
	class sexcat hours;
	var PCSTRESN;
	output out=pc_stat nmiss=nmiss n=n mean=mean stddev=std median=median qrange=qrange;
run;

data sum1;
	set pc_stat;
	
	length nobs mean_dis median_dis qrange_dis $32;
	
	label n='N (# missing)'
			mean='Mean (Std. Dev.)'
			median='Median'
			qrange='Q1 - Q3';
	
	nobs=strip(put(n,5.))||'('||strip(put(nmiss,5.))||')';
	mean_dis=put(mean,5.2)||'('||strip(put(std,5.2))||')';
	median_dis=put(median,5.2);
	qrange_dis=put(qrange,5.2);
run;
	
proc transpose data=sum1 out=sum2;
	by sexcat hours;
	var nobs mean_dis median_dis qrange_dis;
run;

proc sort data=sum2;
	by sexcat hours;
run;

proc print data=sum2;
	by sexcat hours;
run;










