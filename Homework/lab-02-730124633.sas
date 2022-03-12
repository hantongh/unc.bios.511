ods pdf file='/folders/myfolders/BIOS-511/LAB-02/OUTPUT/lab-02-730124633-output.pdf';

ods noproctitle;

libname lab2data "/folders/myfolders/BIOS-511/LAB-02";

*proc contents data=lab2data.dm;
*run;

footnote 'ECHO Data Extract Date: 2017-10-10';

/*********************************************************************
 	SAS Code for Task # 1
*********************************************************************/

title 'Task1: Demographics Data for Select ECHO Trial Subjects';

proc print data=lab2data.dm(obs=10) label noobs;
	var usubjid RFXSTDTC age sex race armcd arm country;
run;

title;

/*********************************************************************
 	SAS Code for Task # 2
*********************************************************************/

title 'Task2: Number and Percent of ECHO Trial Subjects by Treatment Group';

proc freq data=lab2data.dm;
	table armcd/nocum;
run;

title;

/*********************************************************************
 	SAS Code for Task # 3
*********************************************************************/

title 'Task3: Number and Percent of ECHO Trial Subjects by Treatment Group and Country';

proc freq data=lab2data.dm;
	table country*armcd/nopercent norow;
run;

title;

/*********************************************************************
 	SAS Code for Task # 4
*********************************************************************/

data dm;
	set lab2data.dm;
	
	length ageCat $10;
	if not missing(age) and age <65 then ageCat = '1: <65';
	  else if age >= 65		then ageCat = '2: >= 65'; 
	label agecat='Age Category';
run;

title 'Task4: Number and Percent of ECHO Trial Subjects by Treatment Group and Age Category';
			
proc freq data=work.dm;
	table agecat*armcd/missprint nopercent norow;
run;
			
title;


/*********************************************************************
 	SAS Code for Task # 5
*********************************************************************/

title 'Task5: Summary of Age for ECHO Trial Subjects';

proc means data=lab2data.dm n nmiss mean stddev min max;
	var age;
run;

title;


/*********************************************************************
 	SAS Code for Task # 6
*********************************************************************/

title 'Task6: Summary of Age for ECHO Trial Subjects by Treatment Group';

proc means data=lab2data.dm fw=5 n nmiss mean stddev min max;
	class armcd;
	var age;
run;

title;

/*********************************************************************
 	SAS Code for Task # 7
*********************************************************************/

title 'Task7: Distribution of Age for ECHO Trial Subjects by Treatment Group';

ods select histogram;

proc univariate data=lab2data.dm;
	class armcd;
	histogram age/normal;
	inset mean stddev / format=5.2;
run; 

title;


ods pdf close;