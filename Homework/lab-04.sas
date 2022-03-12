ods html file='/folders/myfolders/BIOS-511/LAB-04/lab-04-730124633-output.html';

libname lab4 "/folders/myfolders/BIOS-511/LAB-04";

ods noproctitle;

/*********************************************************************
 	SAS Code for Task # 1
*********************************************************************/

title1 'Task 1: Variables Contained in the AE Dataset';

proc contents data=lab4.ae varnum;
	ods select position;
run;

title;


/*********************************************************************
 	SAS Code for Task # 2
*********************************************************************/

*Part 1;
title1 'Task 2 / Part 1: First 5 Observations in the DM Dataset';

proc sort data=lab4.dm out=work.dm_sorted;
	by USUBJID;
run;

proc print data=work.dm_sorted(obs=5) noobs;
run;
title;

*Part 2;
title1 'Task 2 / Part 2: First 5 Observations in the AE Dataset';

proc sort data=lab4.ae out=work.ae_sorted;
	by USUBJID;
run;

proc print data=work.ae_sorted(obs=5) noobs;
run;
title;


/*********************************************************************
 	SAS Code for Task # 3
*********************************************************************/

*Part 1;
data work.AE2;
	merge work.DM_sorted(keep=usubjid armcd sex 
						race country rfxstdtc rfxendtc)
		  work.AE_sorted;
	by usubjid;
	
	if (aeterm > '');
	drop studyid;
run;

title1 'Task 3 / Part 1: First 15 Observations in the AE2 Dataset';
proc print data=work.ae2(obs=15) noobs;
run;
title;

*Part 2;
data work.AEDM;
	merge work.DM_sorted(keep=usubjid armcd sex 
						race country rfxstdtc rfxendtc)
		  work.AE_sorted;
	by usubjid;
	
	*if (aeterm > '');
	drop studyid;
run;

title1 'Task 3 / Part 2: First 15 Observations in the AEDM Dataset';
proc print data=work.aedm(obs=15) noobs;
run;
title;


/*********************************************************************
 	SAS Code for Task # 4
*********************************************************************/

data work.teae;
	set work.AE2;
	
	length aestyr aestmn aestdy trtstyr trtstmn trtstdy 4;
	format AESTDTI TRTSTDTN date9.;
	label AESTDTI='Imputed AE Onset Date (Numeric)'
			TRTSTDTN='Treatment Start Date (Numeric)';
	
	AESTYR = scan(AESTDTC,1,'-');
	AESTMN = scan(AESTDTC,2,'-');
	AESTDY = scan(AESTDTC,3,'-');
	if AESTDY='' then AESTDY='28';
	AESTDTI = MDY(AESTMN,AESTDY,AESTYR);
	
	TRTSTYR = scan(RFXSTDTC,1,'-');
	TRTSTMN = scan(RFXSTDTC,2,'-');
	TRTSTDY = scan(RFXSTDTC,3,'-');
	if TRTSTDY='' then TRTSTDY='28';
	TRTSTDTN = MDY(TRTSTMN,TRTSTDY,TRTSTYR);
	
	if AESTDTI>=TRTSTDTN then TEAEFN=1;
	else TEAEFN=0;
	
	drop aestyr aestmn aestdy trtstyr trtstmn trtstdy;
run;

/*proc contents data=work.teae;
run;

proc compare base=work.teae compare=lab4.teae_solution;
run;*/


/*********************************************************************
 	SAS Code for Task # 5
*********************************************************************/

title1 'Task 5: Listing of Treatment Emergment AEs with Date Imputation by Country';
title2 'System Organ Class = Infections and Infestations';

proc print data=work.teae noobs label;
	where teaefn=1 and aesoc='Infections and infestations'
			and length(aestdtc)<10;
	 VAR USUBJID AETERM AEDECOD AESTDTC AESTDTI TRTSTDTN;
run;
title;


ods html close;