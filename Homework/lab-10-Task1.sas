/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-10-730124633-Task1.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-11-11
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-10 Task 1. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

libname lab10 '/folders/myfolders/BIOS-511/LAB-10';

proc print data=lab10.pc;
	where usubjid in ('ECHO-011-001', 'ECHO-019-018');
run;
