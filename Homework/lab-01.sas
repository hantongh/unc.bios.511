libname orion "/folders/myfolders/ecprg193";

/* Output Objects

2.When the PROC PRINT step is executed, it
produces one output object. When this simple PROC UNIVARIATE step is executed,
it produces five output objects.
*/

proc print data=orion.employee_payroll(obs=10);
	title 'First 10 Observations of Employee Payroll Data Set';
run;

proc univariate data=orion.employee_payroll;
	var salary;
	title 'Descriptive Statistics for Salary';
run;

/* 
4. One can programmatically use the ODS
TRACE ON; and ODS TRACE OFF; statements around PROC step code to have output
object information printed out to the SAS log. */

ods trace on;

proc print data=orion.employee_payroll;
	title 'First 10 Observations of Employee Payroll Data Set';
run;

proc univariate data=orion.employee_payroll;
	var salary;
	title 'Descriptive Statistics for Salary';
run;

ods trace off;

/* ODS destination

9. The first ODS PDF statement instructs SAS that you want subsequent procedure
steps to write their output into a PDF file. The second ODS PDF statement closes the
PDF destination. */

ods pdf file='/folders/myfolders/BIOS-511/LAB-01/OUTPUT/freq9.pdf';
proc freq data=orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
run;

ods pdf close;

/* 
10. rtf version */

ods rtf file='/folders/myfolders/BIOS-511/LAB-01/OUTPUT/freq10.rtf';
proc freq data=orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
run;

ods rtf close;

* To include the title in the body (not header) part of rtf, use following;

* 'ods noproctitle' turn off title. To turn back, use 'ods proctitle';

ods rtf file='/folders/myfolders/BIOS-511/LAB-01/OUTPUT/freq10_bodytitle.rtf' bodytitle;
proc freq data=orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
run;

ods rtf close;

/*
11. Creating an HTML file is as simple as making
a PDF or RTF file.*/

ods html file='/folders/myfolders/BIOS-511/LAB-01/OUTPUT/freq11.html';
proc freq data=orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
run;

ods html close;

/* Limiting the Output Produced by a Procedure

13. Use the ODS SELECT statement to specify only the output objects you want.
Use the ODS EXCLUDE statement to exclude only the output objects you don’t want.

The syntax of the ODS SELECT/EXCLUDE statements are as follows:
ODS SELECT <output object names>;
ODS EXCLUDE <output object names>;

In order to find the name of the desired ODS output object, 
use one of the two methods discussed above (using ODS TRACE ON/OFF 
is my preferred approach); or simply look in the SAS documentation. 
For example, google “SAS 9.4 PROC FREQ ODS Table Names”. 

Once you know the names of the ODS output objects you want to include
in a file, you can use those names in the ODS SELECT or ODS EXCLUDE
statement. */

ods pdf file='/folders/myfolders/BIOS-511/LAB-01/OUTPUT/select_exclude13.pdf';

title '"Moments and Extreme Observations';
ods select moments extremeobs;
proc univariate data=orion.employee_payroll;
	var salary;
run;

title "Basic Measures, Tests for Location, and Quantiles";
ods exclude moments extremeobs;
proc univariate  data=orion.employee_payroll;
	var salary;
run;

title 'All Univariate Procedure Output';
proc univariate data=orion.employee_payroll;
	var salary;
run;

ods pdf close;


/* Creating Output Data Sets Using ODS

15. To obtain an output data set, you use the ODS OUTPUT statement. 
	
	To use ODS OUTPUT, you need to reference the output objects by name.

The format of the SAS dataset produced does not always resemble the ODS object
you see in printed output.*/

ods pdf file='/folders/myfolders/BIOS-511/LAB-01/OUTPUT/ods_output_15.pdf';

ods pdf select quantiles;
ods output quantiles=salary_quant;
proc univariate data=orion.employee_payroll;
	var salary;
run;

title 'Quantiles for Salary Variable';
proc print data=work.salary_quant;
run;

ods pdf close;


/* ODS Styles

Both SDM and SS/SUE can programmatically produce a list of available
styles using the following PROC step: 

proc template;
	list styles;
run;

*/

ods pdf file='/folders/myfolders/BIOS-511/LAB-01/OUTPUT/fav_style17.pdf' style=journal;
proc freq data=orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Crosstabulations';
run;

ods pdf close;

/* Page Composition with ODS: The STARTPAGE Option

The STARTPAGE option controls when SAS inserts a
page break (and therefore goes to a new page).

By default, STARTPAGE=YES, and SAS inserts a new page at the 
beginning of each procedure’s output. 
In contrast, STARTPAGE=NO is set so that output from multiple
procedures goes onto one page. The STARTPAGE=NO option instructs 
SAS to only start a new page if the current page is filled or when 
you specify STARTPAGE=NOW. */

ods pdf file='/folders/myfolders/BIOS-511/LAB-01/OUTPUT/start_page18.pdf'
	style=journal
	startpage=no;
	
title1 'Descriptive Statistics for Price Variable';
proc means data=orion.employee_payroll;
	class employee_gender;
	var salary;
run;

ods select extremeobs;
proc univariate data=orion.employee_payroll;
	var salary;
run;

ods pdf close;

/*
19. Write a SAS program that uses The CONTENTS Procedure to produce 
a list of variable names and attributes for three datasets in
the orion library: employee_payroll, employee_addresses, and
employee_donations. 

You will direct the output into a PDF file named “contents19.pdf”.

The only output included in the PDF file should be the three ODS 
objects that list the variable names and attributes
 (an example is shown below for one dataset).
 
Use the “minimal” ODS style template for the PDF file that you 
create and ensure that all three ODS objects are included on the 
same page (a one page PDF).*/

ods pdf file='/folders/myfolders/BIOS-511/LAB-01/OUTPUT/contents19.pdf'
	style=minimal
	startpage=no;

ods trace on;

title 'Alphabetic List of Variables and Attributes';

ods select variables;
proc contents data=orion.employee_payroll;
run;

ods select variables;
proc contents data=orion.employee_addresses;
run;

ods select variables;
proc contents data=orion.employee_donations;
run;

ods trace off;

ods pdf close;













