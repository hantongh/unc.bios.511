/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-09-730124633-Task2.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-11-03
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-09 Task 2. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

libname lab9 '/folders/myfolders/BIOS-511/LAB-09';

ods pdf file='/folders/myfolders/BIOS-511/LAB-09/lab-09-730124633.pdf';
ods noproctitle;


* Graph for ALB;

data INPUT_ALB;
	set lab9.ADLB;
	
	length visitcat $8;
	
	if LBTESTCD='ALB';
	
	if lbblfl='Y' then visitcat='Baseline';
	else if visit='Week 16' then visitcat=visit;
	else if visit='Week 32' then visitcat=visit;
	
	if visitcat='' or pct_change=. then delete;
run;

proc means data=input_alb noprint;
	class country visitcat armcd;
	var pct_change;
	output out=plot_alb mean=mean lclm=lclm uclm=uclm;
run;

data plot_alb;
	set plot_alb;
	where _TYPE_=3 or _TYPE_=7;
	if _TYPE_=3 then country='Overall';
	if _TYPE_=7 then
		do;
			if country='CAN' then country='Canada';
			if country='MEX' then country='Mexico';
			if country='USA' then country='United States';
		end;
run;

ods graphics / height=4.5in width=8in;

title1 'Plot of Percent Change in Albumin by Treatment Group';
title2 'Mean +/- 95% Confidence Interval';
proc sgpanel data=plot_alb;
	
	panelby country/columns=4 sort=data;
	
	highlow x=visitcat low=lclm high=uclm/ group=armcd highcap=serif lowcap=serif
											groupdisplay=cluster clusterwidth=0.2;
	
	series x=visitcat y=mean / group=armcd groupdisplay=cluster clusterwidth=0.2
								markers markerattrs=(symbol=circleFilled);
								
	
	
	
	rowaxis label='Percent Change from Baseline';
	colaxis label='Visit Name';
	
	colaxistable _freq_/ class=armcd;
	
run;


* Graph for CA;

data INPUT_CA;
	set lab9.ADLB;
	
	length visitcat $8;
	
	if LBTESTCD='CA';
	
	if lbblfl='Y' then visitcat='Baseline';
	else if visit='Week 16' then visitcat=visit;
	else if visit='Week 32' then visitcat=visit;
	
	if visitcat='' or pct_change=. then delete;
run;

proc means data=input_ca noprint;
	class country visitcat armcd;
	var pct_change;
	output out=plot_ca mean=mean lclm=lclm uclm=uclm;
run;

data plot_ca;
	set plot_ca;
	where _TYPE_=3 or _TYPE_=7;
	if _TYPE_=3 then country='Overall';
	if _TYPE_=7 then
		do;
			if country='CAN' then country='Canada';
			if country='MEX' then country='Mexico';
			if country='USA' then country='United States';
		end;
run;

ods graphics / height=4.5in width=8in;

title1 'Plot of Percent Change in Calcium by Treatment Group';
title2 'Mean +/- 95% Confidence Interval';
proc sgpanel data=plot_ca;
	
	panelby country/columns=4 sort=data;
	
	highlow x=visitcat low=lclm high=uclm/ group=armcd highcap=serif lowcap=serif
											groupdisplay=cluster clusterwidth=0.2;
	
	series x=visitcat y=mean / group=armcd groupdisplay=cluster clusterwidth=0.2
								markers markerattrs=(symbol=circleFilled);
								
	
	
	
	rowaxis label='Percent Change from Baseline';
	colaxis label='Visit Name';
	
	colaxistable _freq_/ class=armcd;
	
run;


* Graph for HCT;

data INPUT_HCT;
	set lab9.ADLB;
	
	length visitcat $8;
	
	if LBTESTCD='HCT';
	
	if lbblfl='Y' then visitcat='Baseline';
	else if visit='Week 16' then visitcat=visit;
	else if visit='Week 32' then visitcat=visit;
	
	if visitcat='' or pct_change=. then delete;
run;

proc means data=input_hct noprint;
	class country visitcat armcd;
	var pct_change;
	output out=plot_hct mean=mean lclm=lclm uclm=uclm;
run;

data plot_hct;
	set plot_hct;
	where _TYPE_=3 or _TYPE_=7;
	if _TYPE_=3 then country='Overall';
	if _TYPE_=7 then
		do;
			if country='CAN' then country='Canada';
			if country='MEX' then country='Mexico';
			if country='USA' then country='United States';
		end;
run;

ods graphics / height=4.5in width=8in;

title1 'Plot of Percent Change in Hematocrit by Treatment Group';
title2 'Mean +/- 95% Confidence Interval';
proc sgpanel data=plot_hct;
	
	panelby country/columns=4 sort=data;
	
	highlow x=visitcat low=lclm high=uclm/ group=armcd highcap=serif lowcap=serif
											groupdisplay=cluster clusterwidth=0.2;
	
	series x=visitcat y=mean / group=armcd groupdisplay=cluster clusterwidth=0.2
								markers markerattrs=(symbol=circleFilled);
								
	
	
	
	rowaxis label='Percent Change from Baseline';
	colaxis label='Visit Name';
	
	colaxistable _freq_/ class=armcd;
	
run;






ods pdf close;