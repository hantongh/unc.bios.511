/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-10-730124633-Task3.sas
*
* Author            : Hantong Hu
*
* Date created      : 2018-11-11
*
* Purpose           : This program is designed to be the sas program for 
						BIOS511 lab-10 Task 3. 
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* YYYY-MM-DD      HH              
*
******************************************************************************/

libname lab10 '/folders/myfolders/BIOS-511/LAB-10';

proc sort data=lab10.pc out=work.pc;
	by usubjid pctptnum;
run;

data pc;
	set pc;
	by usubjid;
	
	format hours 5.2;
	hours=scan(PCTPT,1,' ');
	
	if PCSTRESC='<0.01' then PCSTRESN=0.01;

*manually transpose the data by using arrays;	
	retain hours0-hours10 conc0-conc10;

	array h[11] hours0-hours10;
	array p[11] conc0-conc10;

*initialize values in h[] and p[] to ., and then assign values;
	if first.usubjid then
		do
			i = 1 to dim(h);
			h[i] = .;
			p[i] = .;
  		end;

  h[pcseq] = hours;
  p[pcseq] = pcstresn;

  if last.usubjid and nMiss(of p[*])=0;

* calculate AUC 12;
  AUC12 = 0;
  do i = 1 to dim(h)-1;
    AUC12 = AUC12 + 0.5*(p[i] + p[i+1])*(h[i+1]-h[i]);
  end;


  keep usubjid AUC12;

run;

proc export data=pc
	outfile='/folders/myfolders/BIOS-511/LAB-10/lab-10-730124633-Task3.csv'
	dbms=csv
	replace;
	putnames=no;
run;


