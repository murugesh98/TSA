/* Analysing data */



title "Overall Date Issues in the Data";
proc freq data=tsa.Claims_Cleaned;
	table Date_Issues/ missing nocum nopercent;
run;
title;

ods graphics on;
title "Overall Claims by Year";
proc freq data=tsa.Claims_Cleaned;
	table Incident_Date/ nocum nopercent plots=freqplot;
	format Incident_Date year4.;
	where Date_Issues is null;
run;
title;

%let StateName=Hawaii;

title "&StateName Claim Types, Claim Sites and Disposition";
proc freq data=tsa.Claims_Cleaned order=freq;
	table Claim_Type Claim_Site Disposition/ nocum nopercent;
	where Statename="&StateName" and Date_Issues is null;
run;
title;

title "Close Amount Statistics for &StateName";
proc means data=tsa.Claims_Cleaned mean min max sum maxdec=0;
	var Close_Amount;
	where Statename="&StateName" and Date_Issues is null;
run;
title;
