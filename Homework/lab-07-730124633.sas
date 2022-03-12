/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-07-730124633.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-10-16
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-07. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

libname echo '/folders/myfolders/BIOS-511-FALL-2018-master/data/echo';

ods noproctitle;

/*********************************************************************
 	SAS Code for Task # 1
*********************************************************************/

/*proc import datafile='/folders/myfolders/BIOS-511/LAB-07/ECHO_GENOTYPE.dat'
			out=work.genotype
			dbms=csv
			replace;
run;*/

data genotype;
	infile '/folders/myfolders/BIOS-511/LAB-07/ECHO_GENOTYPE.dat' dlm=',' firstobs=2;

	length site subject 3 genotype $1 reason $20;
	input site subject genotype $ reason $;
	
run;

data dm;
	set echo.dm;
run;

proc sort data=dm;
	by usubjid;
run;

data genotype;
	set genotype;
	
	length USUBJID $12
			sitechar $3
			subchar $3;
	
	sitechar=put(site,z3.);
	subchar=put(subject,z3.);
	USUBJID=catx('-','ECHO',sitechar,subchar);
	
	drop site subject sitechar subchar;
run;

proc sort data=genotype;
	by usubjid;
run;

data dm_gen;
	merge dm genotype;
	by usubjid;
	drop rfxstdtc rfxendtc rficdtc ageu race arm visitnum visit dmdtc;
run;
	

/*********************************************************************
 	SAS Code for Task # 2
*********************************************************************/

proc sort data=echo.vs out=vs;
	by usubjid visitnum visit vstestcd;
	where vstestcd in ('DIABP' 'SYSBP');
run;

data vs_t;
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
	
	
	change_dbp=dbp_wk32-dbp_wk00;
	change_sbp=sbp_wk32-sbp_wk00;
	
run;

proc sort data=vs_t;
	by usubjid;
run;

proc sort data=dm_gen out=geno2 nodupkey;
	where genotype~='' or reason~='';
	by usubjid;
run;

data genotype2;
	merge geno2 vs_t;
	by usubjid;
	keep usubjid sex genotype reason change_dbp change_sbp;
run;

proc sort data=genotype2;
	by usubjid;
	where genotype~='' or reason~='';
run;


/*********************************************************************
 	SAS Code for Task # 3
*********************************************************************/

title 'Summary of Change from Baseline in Systolic and Diastolic Blood Pressure by Genotype';

proc means nway data=genotype2 n mean stddev median min max maxdec=2;
	class genotype/missing;
	label change_dbp='Change in Diastolic Blood Pressure at 32 Weeks'
			change_sbp='Change in Systolic Blood Pressure at 32 Weeks';
	output out=work.results (drop=_type_ rename=(_FREQ_=n))
			mean(change_dbp change_sbp)=dbp sbp;
							
run;

/*********************************************************************
 	SAS Code for Task # 4
*********************************************************************/

proc export data=work.genotype2
			file="/folders/myfolders/BIOS-511/LAB-07/ECHO_GENOTYPE.xlsx"
			dbms=xlsx
			replace; 
	sheet="ECHO";
run;

/*********************************************************************
 	SAS Code for Task # 5
*********************************************************************/

data ECHO_GENOTYPE;
	set work.results;
	if genotype='' then genotype='U';
	
	file "/folders/myfolders/BIOS-511/LAB-07/ECHO_GENOTYPE.csv" dlm=',';
	If _n_=1 then put 'genotype, n, dbp, sbp';

	put genotype n dbp sbp;
run;
















