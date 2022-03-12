/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-13-730124633.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-11-30
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-13. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

%let root        = /folders/myfolders/BIOS-511/LAB-13;
%let echoDat 	 = /folders/myfolders/BIOS-511-FALL-2018-master/data/echo;
%let analysisDat = &root./data;
%let outputPath = &root./output;

libname echo "&echoDat." access=read;
libname out "&analysisDat.";

* Step 1: Import data into work.ranges;

data ranges;
	infile "&analysisDat./qc_dates.csv" firstobs=4 delimiter=',';
	length country $3 sitenum 3 stdate eddate $9 period 3;
	input country:$3. sitenum:2. stdate eddate:$char. period:1.;
	* stdate and eddate in char;
	
	stdy=scan(stdate,1,'-');
	stmn=upcase(scan(stdate,2,'-'));
	styr=scan(stdate,3,'-');
	
	eddy=scan(eddate,1,'-');
	edmn=upcase(scan(eddate,2,'-'));
	edyr=scan(eddate,3,'-');
	
	startdate=input(catx('',stdy,stmn,styr),date9.);
	enddate=input(catx('',eddy,edmn,edyr),date9.);
	
	format startdate enddate yymmdd10.;
	
	keep country sitenum startdate enddate period;
run;


* Step 2: Create variable;

proc sort data=ranges(keep=country sitenum) out=mac nodupkey;
	by country sitenum;
run;


data _null_;
	set mac end=last;
	
	call symput('SITE'||strip(_n_), strip(sitenum));
	
	if last=1;
	call symput('NUMSITES',strip(_n_));
run;

* Step 3: Use PROC SQL to merge dm data set and work.ranges;

data dm;
	set echo.dm;
	
	date=input(strip(input(RFICDTC,yymmdd10.)),12.);
	siteid=input(scan(usubjid,2,'-'),best.);
run;

proc sql;
	create table subjects as
	select dm.usubjid,dm.siteid,
		ranges.sitenum,ranges.country,ranges.startdate,ranges.enddate
	from dm,ranges
	where dm.siteid = ranges.sitenum and	
			dm.country = ranges.country and
			ranges.startdate <= dm.date and
			dm.date <= ranges.enddate;
quit;



* Step 4 Create macro;

proc sort data=echo.vs out=vs;
	by usubjid;
run;

%macro gen_report;
%do i = 1 %to &numsites.;

	data temp;
		set subjects;
		where sitenum=&&SITE&i.;
		
		label subnum='Subject Number';
		subnum=strip(scan(usubjid,3,'-'));
		
		call symput('cnt',country);
		call symput('site',put(sitenum,z3.));
	run;
	
	proc sort data=temp;
		by usubjid;
	run;

	data temp2;
		merge temp vs;
		by usubjid;
		if sitenum;
		
		if visit='Week 8' then visit='Week 08';
		
		keep usubjid vstestcd vsstresn visit;
	run;

	proc sort data=temp2;
		by usubjid visit;
	run;

	data temp3;
		set temp2;
		by usubjid visit;
		
		retain dbp height hr sbp weight;
		array p[5] dbp height hr sbp weight;
	
		if first.visit then
			do i = 1 to dim(p);
				p[i] = .;
			end;
		
		if vstestcd = 'DIABP' then col = 1;
		else if vstestcd = 'HEIGHT' then col = 2;
		else if vstestcd = 'HR' then col = 3;
		else if vstestcd = 'SYSBP' then col = 4;
		else if vstestcd = 'WEIGHT' then col = 5;
 		
 		p[col] = vsstresn;
 	
 		if last.visit;
 	
		keep usubjid visit dbp height hr sbp weight;
	run;
	
	data temp4;
		merge temp(keep=usubjid sitenum country subnum) temp3;
		by usubjid;
		
		label visit='Visit Name'
				dbp='Diastolic Blood Pressure'
				height='Height'
				hr='Heart Rate'
				sbp='Systolic Blood Pressure'
				weight='Weight';
				
		if visit='Week 08' then visit='Week 8';
		
	run;
	
	ods pdf file="&outputPath./&cnt._&site._VITAL_SIGNS.pdf";
	
	title "Site 0&&SITE&i. Vital Sign Data for Select Subjects";
	proc print data=temp4 label noobs;
		by subnum;
		var visit dbp height hr sbp weight;
	run;

	ods pdf close;
	
%end;
%mend;

%gen_report;








