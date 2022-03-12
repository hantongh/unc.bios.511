%macro FREQ(INSTRUCTIONS=);

%let numvar=%sysfunc(countw(&INSTRUCTIONS));

	%do i=1 %to &numvar.;
  		%let var&i = %scan(&INSTRUCTIONS, &i,'*|',M);
	%end;
	
	
  	%do j=1 %to %eval(&numvar/2);
  		
  		%let item=%eval(-1+2*&j.);
  		%let form=%eval(2*&j.);
  			
  		%if "&&var&form."="NONE" %then %do;
  			data temp;
  				set analysis.adsis;
  				
  				where qstestcd="&&var&item.";
  				
  				call symputx('title',qstest);
  				call symputx('itemnum',qsseq);
  				
  				keep usubjid aval;
  			run;
  		%end;
  			
  		%else %do;
  			data temp;
  				set analysis.adsis;
  				
  				format aval &&var&form...;
  				where qstestcd="&&var&item.";
  				
  				call symputx('title',qstest);
  				call symputx('itemnum',qsseq);
  				
  				keep usubjid aval;
  			run;
  		%end;
  		
  		title1 "Frequency Analysis of Survey Item &itemnum.";
  		title2 "&title.";
  		proc freq data=temp noprint;
  			table aval/nocum out=tab;
		run;
			
		data tab;
			set tab;
			label aval='Analysis Value'
					count='Frequency Count'
					percent='Percent of Total Frequency';
					
			format percent best6.2;
		run;
			
		proc print data=tab label split=' ' noobs;
			where aval ne .;
		run;
			
  	%end;
	
%mend;
