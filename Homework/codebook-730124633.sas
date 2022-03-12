%macro codebook(lib=,ds=,maxVal=10);

	data &ds.;
 		set &lib..&ds.;
	run;

	proc contents data = &ds. out = contents varnum noprint; run;

	proc sort data=contents;
		by varnum;
	run;

	data _null_;
		set contents end=last;
  
		length typec $4;
		if type = 1 then typec = 'Num';
		else typec = 'Char';
 
		call symput('var'||strip(put(_n_,best.)),strip(name));
		call symput('label'||strip(put(_n_,best.)),strip(label));
		call symput('type'||strip(put(_n_,best.)),strip(typec));
 
		if last = 1;

		call symput('numVars',strip(put(_n_,best.)));
	run;

	%do i = 1 %to &numVars.;

		%if %upcase(&&type&i) = NUM %then %do;
			title "Analysis of Variable = &&var&i (&&label&i)";
					proc means data = &ds. n nmiss mean stddev median min max;
						var &&var&i;
					run;
			%end;


      	%if %upcase(&&type&i) = CHAR %then %do;
      			proc freq data = &ds. order=freq noprint;
      				label &&var&i='Value';
					table &&var&i/nocum out=temp;
      			run;
      			
      			data _null_;
      				set temp;
      				id=_n_;
      				call symputx('count',id);
      			run;
      			
      			%if &count.>&maxVal. %then %do;
      				title "&maxVal. Most Frequency Analysis of Variable &&var&i (&&label&i)";
      			 	proc print data=temp(obs=&maxVal.) noobs label;run;
      			%end;
      			%else %do;
      				title "Frequency Analysis of Variable = &&var&i (&&label&i)";
      			 		proc print data=temp noobs label;run;
      			%end;
      	
      	%end;
      	
	%end;

%mend;
