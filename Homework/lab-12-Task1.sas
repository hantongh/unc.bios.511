/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-12-730124633-Task1.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-11-25
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-12 task 1. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

%let root        = /folders/myfolders/BIOS-511/LAB-12;
%let echoDat 	 = /folders/myfolders/BIOS-511-FALL-2018-master/data/echo;
%let analysisDat = &root./data;
%let outputPath = &root./output;
%let macroPath = &root./macros;


libname echo "&echoDat." access=read;
libname out "&analysisDat.";

* Split out and create USUBJID ARMCD ARM AGE AGECAT COUNTRY (in order)
	from DM data set;
data work.dm_raw;
	set echo.dm;
	
	length AGECAT $5;
	label AGECAT='Age Category';
	
	if age=. then agecat='';
	else if age<45 then agecat='<45';
	else if 45<=age and age<55 then agecat='45-55';
	else agecat='>=55';
	
	keep USUBJID ARMCD ARM AGE AGECAT COUNTRY;
run;

data work.dm_order;
	retain USUBJID ARMCD ARM AGE AGECAT COUNTRY;
	set work.dm_raw;
run;


* Create variable PCMAX from PC data set;
proc sort data=echo.pc out=work.pc_sorted;
	by usubjid;
run;

data work.pc;
	set echo.pc;
	
	by usubjid;
	
	length PCMAX 8;
	label PCMAX='Maximum Plasma Concentration';
	
	if PCSTRESN=. then PCSTRESN=0.01;
	
	*manually transpose the data by using arrays;	
	retain conc0-conc10;

	array p[11] conc0-conc10;

	*initialize values in p[] to ., and then assign values;
	if first.usubjid then
		do i = 1 to dim(p);
			p[i] = .;
  		end;
	p[pcseq] = pcstresn;

	*Set PCMAX;
	if 1 then
		do j=1 to dim(p);
			if p[j]>pcmax then pcmax=p[j];
		end;

	if last.usubjid; 
	
	keep USUBJID PCMAX;
run;


* Create var DIABP_CHANGE SYSBP_CHANGE HR_CHANGE WGT_CHANGE
	from VS data set;
proc sort data=echo.vs out=work.vs_sorted;
	by usubjid vsseq;
run;

data vs_diabp vs_sysbp vs_hr vs_wgt;
	set vs_sorted(keep=usubjid vsseq vstestcd vsstresn visit);
	
	if 12<vsseq<=18 then vsseq=vsseq-12;
	else if 18<vsseq<=24 then vsseq=vsseq-18;
	else if 24<vsseq<=30 then vsseq=vsseq-24;
	
	select(vstestcd);
		when('DIABP') output vs_diabp;
		when('SYSBP') output vs_sysbp;		
		when('HR') output vs_hr;
		when('WEIGHT') output vs_wgt;
		otherwise;
	end;
run;


%macro change(dsn=);

data &dsn;
	set vs_&dsn.;
	by usubjid;
	
	length &dsn._change 8;
	*label &dsn_change='Change in Diastolic Blood Pressure';
	
	*manually transpose the data by using arrays;	
	retain &dsn.0-&dsn.5;

	array p[6] &dsn.0-&dsn.5;

	*initialize values in p[] to ., and then assign values;
	if first.usubjid then
		do i = 1 to dim(p);
			p[i] = .;
  		end;
	p[vsseq] = vsstresn;

	if last.usubjid; 
	
	initial=(&dsn.0+&dsn.1)/2;
	after=(&dsn.2+&dsn.3+&dsn.4+&dsn.5)/4;
	
	&dsn._change=after-initial;
	
	keep USUBJID &dsn._change;
run;

%mend;

%change(dsn=diabp)
%change(dsn=sysbp)
%change(dsn=hr)
%change(dsn=wgt);


* Merge into ADSL;
data adsl;
	merge dm_order pc diabp sysbp hr wgt;
	by usubjid;
	
	label diabp_change='Change in Diastolic Blood Pressure'
			SYSBP_CHANGE='Change in Systolic Blood Pressure'
			HR_CHANGE='Change in Heart Rate'
			WGT_CHANGE='Change in Weight';
run;


* Data set output to /data;
data out.ADSL;
	set adsl;
run;


/*
* Compare with solution;
proc compare data=adsl compare=echo.adsl;
run;

proc contents data=adsl;
run;

*/


