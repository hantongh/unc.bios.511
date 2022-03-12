/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : PART2-730124633.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-12-09
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 Final exam Part 2. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

%let root        = /folders/myfolders/BIOS-511/FINAL;
%let analysisDat = &root./analysis_data;
%let qualDat = &root./qualtrics_data;
%let macro = &root./macros;
%let outputPath = &root./output;

libname analysis "&analysisDat.";
libname out "&outputPath.";

data adsis2;
	set analysis.adsis;
	
	where qsseq=17;
	keep usubjid qstestcd aval;

run;

ods pdf file="&outputPath./PART2-730124633.pdf" nogtitle;

ods graphics / height=4in width=6in noborder;
ods startpage=off;

title 'Distribution of SIS-16 Scores';

proc sgplot data=adsis2;
	histogram aval/  fillattrs=(color=lightRed) scale=proportion binwidth=12;
	xaxis label='SIS-16 Score' values=(0 to 105 by 10);
	yaxis label='Proportion' grid values=(0 to 0.6 by 0.1);
run;

proc sgplot data=adsis2;
	hbox aval/ fillattrs=(color=lightRed);
	xaxis label='SIS-16 Score' grid values=(0 to 100 by 10);
run;
title;



ods pdf close;