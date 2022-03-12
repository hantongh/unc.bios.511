/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-08-730124633.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-10-23
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-08. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

libname echo '/folders/myfolders/BIOS-511-FALL-2018-master/data/echo';

ods pdf file='/folders/myfolders/BIOS-511/LAB-08/lab-08-730124633.pdf';
ods noproctitle;

/*********************************************************************
 	SAS Code for Task # 1 / Step # 1
*********************************************************************/

title "Task 1 - Step 1: Number of Subjects by Treatment Group";
proc sgplot data = echo.DM;
	vbar armcd;
run;


/*********************************************************************
 	SAS Code for Task # 1 / Step # 2
*********************************************************************/

title "Task 1 - Step 2: Number of Subjects by Treatment Group";
proc sgplot data = echo.DM;
	vbar armcd / fillattrs=(color=lightRed) transparency=0.5;
run;


/*********************************************************************
 	SAS Code for Task # 1 / Step # 3
*********************************************************************/

title "Task 1 - Step 3: Number of Subjects by Treatment Group";
proc sgplot data = echo.DM;
	vbar armcd / fillattrs=(color=lightRed) dataskin=pressed;
run;


/*********************************************************************
 	SAS Code for Task # 1 / Step # 4
*********************************************************************/

title "Task 1 - Step 4: Number of Subjects by Treatment Group";
proc sgplot data = echo.DM;
	vbar armcd / fillattrs=(color=lightRed) dataskin=pressed stat=percent;
	xaxis label ='Treatment Group';
	yaxis label='Percent (%)' grid;
run;


/*********************************************************************
 	SAS Code for Task # 1 / Step # 5
*********************************************************************/

ods pdf nogtitle;

title "Task 1 - Step 5: Number of Subjects by Treatment Group";
proc sgplot data = echo.DM;
	vbar armcd / fillattrs=(color=lightRed) dataskin=pressed stat=percent;
	xaxis label ='Treatment Group';
	yaxis label='Percent (%)' grid;
run;

ods pdf gtitle;


/*********************************************************************
 	SAS Code for Task # 2 / Step # 1
*********************************************************************/

title1 "Task 2 - Step 1: Number of Subjects by Sex and Treatment Group";
proc sgplot data = echo.DM;
	vbar sex / group=armcd stat=percent;
	label armcd = 'Treatment Group';
	keylegend / position=right location=outside border;
run;


/*********************************************************************
 	SAS Code for Task # 2 / Step # 2
*********************************************************************/

title1 "Task 2 - Step 2: Number of Subjects by Sex and Treatment Group";
proc sgplot data = echo.DM;
	vbar sex / group=armcd groupdisplay=cluster stat=percent;
	label armcd = 'Treatment Group';
run;


/*********************************************************************
 	SAS Code for Task # 3
*********************************************************************/

proc sort data=echo.dm out=work.dm;
	by usubjid;
run;

proc sort data=echo.vs out=work.vs;
	by usubjid;
run;

data vs_t;
	set vs;
	where visit='Screening';
	by usubjid;
	
	retain diabp height hr sysbp weight bmi;
	array sign[1,5] diabp height hr sysbp weight;
	
	if first.usubjid then do;
		diabp=.; height=.; hr=.; sysbp=.; weight=.;
	end;
	
	if vstestcd='DIABP' then cat=1;
	else if vstestcd='HEIGHT' then cat=2;
	else if vstestcd='HR' then cat=3;
	else if vstestcd='SYSBP' then cat=4;
	else if vstestcd='WEIGHT' then cat=5;
	
	sign[1,cat]=vsstresn;
	
	bmi=weight/((height/100)*(height/100));
	format bmi 5.2;
	
	if last.usubjid;
	
	label diabp='Diastolic Blood Pressure'
			height='Height'
			hr='Heart Rate'
			sysbp='Systolic Blood Pressure'
			weight='Weight'
			bmi='Body Mass Index';
	
	keep usubjid diabp height hr sysbp weight bmi;

run;

data WORK.DM_all;
	merge dm vs_t;
	keep USUBJID AGE sex armcd country diabp height hr sysbp weight bmi;
run;

data work.DM_USA;
	set work.dm_all;
	where country='USA';
	drop country;
run;


/*********************************************************************
 	SAS Code for Task # 4 / Step # 1
*********************************************************************/

title1 "Task 4 - Step 1: Scatter plot of Height by Body Mass Index";
proc sgplot data = DM_USA;
	scatter x=height y=BMI;
run;


/*********************************************************************
 	SAS Code for Task # 4 / Step # 2
*********************************************************************/

title1 "Task 4 - Step 2: Scatter plot of Height by Body Mass Index";
proc sgplot data = DM_USA;
	scatter x=height y=BMI / markerattrs=(symbol=circleFilled color=darkBlue);
	xaxis label="Height (cm)" values=(150 to 210 by 10);
	yaxis values=(5 to 35 by 5);
run;


/*********************************************************************
 	SAS Code for Task # 4 / Step # 3
*********************************************************************/

proc format;
	value $gend
			'M'='Male'
			'F'='Female';
run;

title1 "Task 4 - Step 3: Scatter plot of Height by Body Mass Index";
proc sgplot data = DM_USA;
	format sex $gend.;
	scatter x=height y=BMI / markerattrs=(symbol=circleFilled) group=sex;
	xaxis label="Height (cm)" values=(150 to 210 by 10);
	yaxis values=(5 to 35 by 5);
run;


/*********************************************************************
 	SAS Code for Task # 5 / Step # 1
*********************************************************************/

title1 "Task 5 - Step 1: Scatter plot of Height by Body Mass Index";
proc sgplot data = DM_USA;
	scatter x=height y=BMI;
run;


/*********************************************************************
 	SAS Code for Task # 5 / Step # 2
*********************************************************************/

ods graphics / height=4in width=4in noborder;
title1 "Task 5 - Step 2: Scatter plot of Height by Body Mass Index";
proc sgplot data = DM_USA;
	scatter x=height y=BMI;
run;
ods graphics / reset=all;


/*********************************************************************
 	SAS Code for Task # 6
*********************************************************************/

proc format;
	value $ trt
		 "ECHOMAX" = "Investigational Treatment"
		 "PLACEBO" = "Placebo";
run;

proc sort data = DM_USA out = DM_USA2;
	by armcd;
run;

option nobyline;
title1 "Task 6: Scatter plot of Height by Body Mass Index";
title2 "Treatment Group = #byval(armcd)";

proc sgplot data = DM_USA2 noautolegend;
	by armcd;
	format armcd $trt.;
	reg x=height y=BMI / markerattrs=(size=4 symbol=diamondFilled color=Blue)
						lineattrs=(pattern=2 thickness=2 color=darkRed);
run;

option byline;


/* End of Lab 08 */


ods pdf close;