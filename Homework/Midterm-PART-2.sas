/*****************************************************************************
* Project           : BIOS 511 Midterm
*
* Program name      : S730124633-PART-2.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-10-14
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 Midterm Part 2. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 2018-10-14      HH              
*
******************************************************************************/

ods pdf file='/folders/myfolders/BIOS-511/MIDTERM/S730124633-PART-2.pdf';

libname midterm "/folders/myfolders/BIOS-511/MIDTERM";

ods noproctitle;


data ae;
	set midterm.ae;
	
	length aestyr aestmn aestdy 4
			aeenyr aeenmn aeendy 4;
	format AESTDTI AEENDTI yymmdd10.;
	label AESTDTI='Imputed AE Onset Date (Numeric)'
			AEENDTI='Imputed AE End Date (Numeric)';
	
	AESTYR = scan(AESTDTC,1,'-');
	AESTMN = scan(AESTDTC,2,'-');
	AESTDY = scan(AESTDTC,3,'-');
	
	AEENYR = scan(AEENDTC,1,'-');
	AEENMN = scan(AEENDTC,2,'-');
	AEENDY = scan(AEENDTC,3,'-');
	
	if AESTDY='' then AESTDY='15';
	AESTDTI = input(catx('/',AESTYR,AESTMN,AESTDY),yymmdd10.);
	
	if aeenyr='' then aeendti=.;
	else AEENDTI = input(catx('/',AEENYR,AEENMN,AEENDY),yymmdd10.);

	if aeendti~=. and AESTDTI>AEENDTI then AESTDTI=AEENDTI;

	drop aestyr aestmn aestdy aeenyr aeenmn aeendy;
run;

proc sort data=midterm.dm out=dm;
	by usubjid;
run;

proc sort data=ae;
	by usubjid;
run;

proc format;
	value expFormat
		.='No AE'
		0='HAS AE No TE'
		1='HAS TE';

data aedm;
	merge dm ae;
	by usubjid;
	
	first=input(RFXSTDTC,yymmdd10.);
	last=input(RFXENDTC,yymmdd10.);
	format first last yymmdd10.;
	
	drop ageu race arm visitnum visit aeterm aesoc;
	label ae_exp='Experience adverse event';
	if AESTDTI=. then ae_exp=.;
	else if AESTDTI>=first and AESTDTI<last+15 then
		ae_exp=1;
	else ae_exp=0;
	
	format ae_exp expFormat.;
run;


/*********************************************************************
 	SAS Code for Q1 Q2
*********************************************************************/

title 'Q1-2: Distribution of adverse event';
proc sort data=aedm;
	by usubjid ae_exp;
run;

data aedm_dis;
	set aedm;
	by usubjid;
	if last.usubjid=1;
run;

ods select CrossTabFreqs;
proc freq data=aedm_dis;
	table armcd*ae_exp/missing nocol norow;
run;

title;


/*********************************************************************
 	SAS Code for Q3
*********************************************************************/

title 'Q3: Distribution of seriousness';
proc sort data=aedm out=aedm_ser;
	by usubjid aeser;
run;

data aedm_sermax;
	set aedm_ser;
	by usubjid;
	if last.usubjid;
	if armcd='ECHOMAX';
run;

data aedm_serbo;
	set aedm_ser;
	by usubjid;
	if last.usubjid;
	if armcd='PLACEBO';
run;

proc freq data=aedm_sermax noprint;
	tables aeser/nocum out=freq_sermax;
run;

proc freq data=aedm_serbo noprint;
	tables aeser/nocum out=freq_serbo;
run;


data freq_ser;
	merge freq_sermax (rename=(Count=ECHOMAXNUM
								Percent=ECHOMAXPER))
			freq_serbo (rename=(Count=PLACEBONUM
								Percent=PLACEBOPER));
	by aeser;
	
	length percentdif 8;
	percentdif=echomaxper-placeboper;
	format percentdif 6.2;
	label percentdif='Difference in %';
run;

proc print data=freq_ser label noobs;
run;

title;

/*********************************************************************
 	SAS Code for Q4
*********************************************************************/

proc sort data=aedm;
	by usubjid;
run;

proc format;
	value aenumcat
		3-high='3 or more AE'
		other='Other';
run;

/*
data aedm_num;
	set aedm;
	by usubjid;
	
	label num_ae='Number of adverse event';
	
	if count=. then count=0;
	
	if LAST.usubjid=0 then
		do;
			if ae_exp~=. then count+1;
		end;
	else if LAST.usubjid=1 then
		do;
			if ae_exp=. then
				do;
					num_ae=0;
				end;
			else
				do;
					num_ae=count+1;
				end;
		count=0;
		end;
	
	drop count;
	format num_ae aenumcat.;
run;
*/

proc freq data=aedm noprint;
	table usubjid/nocum nopercent out=aedm_num;
run;

data aedm_num;
	set aedm_num;
	
	format count aenumcat.;
run;

title 'Q4: Distribution of # of adverse event for each subject';
proc freq data=aedm_num;
	table count/ nocum nopercent;
run;
title;


/*********************************************************************
 	SAS Code for Q5
*********************************************************************/

title 'Q5: Mean adverse event duration in days';
data aedm_dur;
	set aedm;
	where aeendtc~='';
	
	label duration='AE Duration';
	
	duration=aeendti-aestdti+1;
	keep usubjid aestdti aeendti duration;
run;

proc means data=aedm_dur n mean maxdec=2;
	var duration;
run;
title;




ods pdf close;