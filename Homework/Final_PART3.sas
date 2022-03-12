/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : PART3-730124633.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-12-09
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 Final exam Part 3. 
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

libname raw "&qualDat." access=read;
libname analysis "&analysisDat.";
libname out "&outputPath.";

proc format;
	value fmtA
			1-3 = 'At Least Somewhat Difficult'
			4 = 'A Little Difficult'
			5 = 'No Difficulty';
	value fmtB
			1-4 = 'At Least Some Difficulty'
			5 = 'No Difficulty';
run;


%include "&macro./PART3-FREQ-730124633.sas";

ods pdf file="&outputPath./PART3-730124633.pdf";
%FREQ(INSTRUCTIONS = ITEM01*FMTA|ITEM01*FMTB|ITEM01*NONE);
ods pdf close;


















