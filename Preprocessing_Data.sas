/* Accessing Data */

%let path=/folders/myfolders/ECRB94/data;
libname tsa "&path";

options validvarname=v7;

proc import datafile="&path/TSAClaims2002_2017.csv"
			dbms=csv
			out=tsa.ClaimsImport
			replace;
	guessingrows=max;
run;

/* Exploring data */

proc print data=tsa.ClaimsImport(obs=20);
run;

proc contents data=tsa.ClaimsImport varnum;
run;

proc freq data=tsa.ClaimsImport;
	tables claim_site
			disposition
			claim_type
			date_received
			incident_date / nocum nopercent;
	format incident_date date_received year4.;
run;

proc print data=tsa.ClaimsImport;
	where date_received < incident_date;
	format date_received incident_date date9.;
run;

/* Preparing Data */

proc sort data=tsa.ClaimsImport
			out=tsa.Claims_NoDups noduprecs;
	by _all_;
run;

proc sort data=tsa.Claims_NoDups;
	by Incident_Date;
run;

data tsa.claims_cleaned label;
	set tsa.claims_nodups;
	
	if Claim_Site in('-','') then Claim_Site="Unknown";
	
	if Disposition in ('-',"") then Disposition="Unknown";
		else if Disposition='losed: Contractor Claim' then Disposition="Closed:Contractor Claim";
		else if Disposition='Closed: Canceled' then Disposition="Closed:Canceled";
		
	if Claim_Type in ('-','') then Claim_Type="Unknown";
		else if Claim_Type='Passenger Property Loss/Personal Injur' then Claim_Type="Passenger Property Loss";
		else if Claim_Type='Passenger Property Loss/Personal Injury' then Claim_Type="Passenger Property Loss";
		else if Claim_Type='Property Damage/Personal Injury' then Claim_Type="Property Damage";
		
	State=upcase(state);
	StateName=propcase(StateName);
	
	if(Incident_Date > Date_Received or
		Date_Received = . or
		Incident_Date = . or
		year(Incident_Date) < 2002 or
		year(Incident_date) > 2017 or
		year(Date_Received) < 2002 or
		year(Date_Received) > 2017) then Date_Issues="Needs review";
	
	format Incident_Date Date_Received date9. Close_Amount Dollar20.2;
	label Airport_Code="Airport Code"
		  Airport_Name="Airport Name"
		  Claim_Number="Claim Number"
		  Claim_Site="Claim Site"
		  Claim_Type="Claim Type"
		  Close_Amount="Close Amount"
		  Date_Issues="Date Issues"
		  Date_Received="Date Received"
		  Incident_Date="Incident Date"
		  Item_Category="Item Category";
	
	drop county city;

run;

proc freq data=tsa.Claims_Cleaned order=freq;
	tables Claim_Site
			Disposition
			Claim_Type
			Date_Issues/ nopercent nocum;
run;
