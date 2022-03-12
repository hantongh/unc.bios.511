/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-12-730124633-Task2.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-11-25
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-12 task 2. 
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
libname out "&analysisDat." access=read;


ods noproctitle;


ods noptitle; option nonumber nodate;
%include "&macroPath./codebook-730124633.sas";

ods pdf file="&outputPath./ADSL_CODEBOOK.pdf" style=sasweb;
%codebook(lib=out,ds=adsl,maxVal=15);
ods pdf close;

ods pdf file="&outputPath./DM_CODEBOOK.pdf" style=sasweb;
%codebook(lib=echo,ds=dm);
ods pdf close;












