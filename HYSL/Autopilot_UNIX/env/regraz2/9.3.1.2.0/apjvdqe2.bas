Hyperion Provider Services - Release 9.3.1.2.00 Build 005
Copyright (c) 1991, 2007 Oracle and / or its affiliates. All rights reserved.
connection mode : EMBEDDED
essbase.properties: <<>MASK<>>/bin/essbase.properties
domain.db location: <<>MASK<>>/data/domain.db
console log enable : false
file log enable : true
logFileName : ../bin/apsserver.log
logRequest : false
logLevel : WARN
java System properties -DESS_ES_HOME: <<>MASK<>>
Query Results for the Operation: conditionalRetrieve
-----------------------------------------------------
		Actual	Sales		
		Jan	Feb	Mar	
     Market	     Product	49896.0	45668.0	45681.0	
 	Audio	15326.0	14137.0	14623.0	
 	Visual	34570.0	31531.0	31058.0	
East	     Product	18549.0	16226.0	16204.0	
 	Audio	6338.0	5767.0	6027.0	
 	Visual	12211.0	10459.0	10177.0	
West	     Product	22679.0	21140.0	21374.0	
 	Audio	8988.0	8370.0	8596.0	
 	Visual	13691.0	12770.0	12778.0	
South	     Product	8668.0	8302.0	8103.0	
 	Audio	#Missing	#Missing	#Missing	
 	Visual	8668.0	8302.0	8103.0	


Query Results for the Operation: retrieve
-----------------------------------------------------
		Product	Market		
		Jan	Feb	Mar	
Actual	Sales	49896.0	45668.0	45681.0	


Query Results for the Operation: zoomIn
-----------------------------------------------------
			Product			
			Jan	Feb	Mar	
East	Actual	Sales	18549.0	16226.0	16204.0	
West	Actual	Sales	22679.0	21140.0	21374.0	
South	Actual	Sales	8668.0	8302.0	8103.0	
     Market	Actual	Sales	49896.0	45668.0	45681.0	


Query Results for the Operation: conditionalZoomIn
-----------------------------------------------------
	Product	Actual	Sales		
	Jan	Feb	Mar		
East	18549.0	16226.0	16204.0		
West	22679.0	21140.0	21374.0		
South	8668.0	8302.0	8103.0		
     Market	49896.0	45668.0	45681.0		


Query Results for the Operation: zoomOut
-----------------------------------------------------
		Product	Market	
		Qtr1		
Actual	Sales	141245.0		


Name: East
Level: 1
Generation: 2
Consolidation: + (addition)
Formula: null
Dimension name: Market
Child count: 3
Parent name: Market
Member number: 4
Dimension number: 2
Name: West
Level: 1
Generation: 2
Consolidation: + (addition)
Formula: null
Dimension name: Market
Child count: 4
Parent name: Market
Member number: 9
Dimension number: 2
Name: South
Level: 1
Generation: 2
Consolidation: + (addition)
Formula: null
Dimension name: Market
Child count: 3
Parent name: Market
Member number: 13
Dimension number: 2
Name: Market
Level: 2
Generation: 1
Consolidation: + (addition)
Formula: null
Dimension name: Market
Child count: 3
Parent name: 
Member number: 14
Dimension number: 2
Name: Audio
Level: 1
Generation: 2
Consolidation: + (addition)
Formula: null
Dimension name: Product
Child count: 2
Parent name: Product
Member number: 3
Dimension number: 3
Name: Visual
Level: 1
Generation: 2
Consolidation: + (addition)
Formula: null
Dimension name: Product
Child count: 3
Parent name: Product
Member number: 7
Dimension number: 3
Name: Product
Level: 2
Generation: 1
Consolidation: + (addition)
Formula: null
Dimension name: Product
Child count: 2
Parent name: 
Member number: 8
Dimension number: 3
Name: Qtr1, Desc: , Level Num: 1, Gen Num: 2, Child count: 3, Dim Name: Year, Dim Category: None
Name: Qtr2, Desc: , Level Num: 1, Gen Num: 2, Child count: 3, Dim Name: Year, Dim Category: None
Name: Qtr3, Desc: , Level Num: 1, Gen Num: 2, Child count: 3, Dim Name: Year, Dim Category: None
Name: Qtr4, Desc: , Level Num: 1, Gen Num: 2, Child count: 3, Dim Name: Year, Dim Category: None
Query Results for the Operation: keepOnly
-----------------------------------------------------
		Product	Market	
		Feb		
Actual	Sales	45668.0		


Query Results for the Operation: removeOnly
-----------------------------------------------------
		Product	Market	
		Jan	Feb	
Actual	Sales	49896.0	45668.0	


Query Results for the Operation: pivot
-----------------------------------------------------
				Product		
			Jan	Feb	Mar	
Market	Actual	Sales	49896.0	45668.0	45681.0	


Query Results for the Operation: report
-----------------------------------------------------
	Market	Product	Accounts	Scenario		
Jan	10661.0					
Feb	8716.0					
Mar	8434.0					
  Qtr1	27811.0					
Apr	7165.0					
May	8435.0					
Jun	7324.0					
  Qtr2	22924.0					
Jul	8562.0					
Aug	8963.0					
Sep	13455.0					
  Qtr3	30980.0					
Oct	12686.0					
Nov	17262.0					
Dec	22317.0					
  Qtr4	52265.0					
    Year	133980.0					


Query Results for the Operation: reportFile
-----------------------------------------------------
	
                         Sales Actual Stereo 	
	
                     Qtr1     Qtr2     Qtr3     Qtr4 	
                 ======== ======== ======== ======== 	
	
East                7,839    7,933    7,673   10,044 	
West               11,633   11,191   11,299   14,018 	
South            #Missing #Missing #Missing #Missing 	
  Market           19,472   19,124   18,972   24,062 	
	
                      Sales Actual Compact_Disc 	
	
                     Qtr1     Qtr2     Qtr3     Qtr4 	
                 ======== ======== ======== ======== 	
	
East               10,293    9,702    9,965   11,792 	
West               14,321   14,016   14,328   17,247 	
South            #Missing #Missing #Missing #Missing 	
  Market           24,614   23,718   24,293   29,039 	
	
                          Sales Actual Audio 	
	
                     Qtr1     Qtr2     Qtr3     Qtr4 	
                 ======== ======== ======== ======== 	
	
East               18,132   17,635   17,638   21,836 	
West               25,954   25,207   25,627   31,265 	
South            #Missing #Missing #Missing #Missing 	
  Market           44,086   42,842   43,265   53,101 	


Query Results for the Operation: report_with_no_parsing
-----------------------------------------------------
	Market	Product	Accounts	Scenario	
Jan	10,661
Feb	8,716
Mar	8,434
  Qtr1	27,811
Apr	7,165
May	8,435
Jun	7,324
  Qtr2	22,924
Jul	8,562
Aug	8,963
Sep	13,455
  Qtr3	30,980
Oct	12,686
Nov	17,262
Dec	22,317
  Qtr4	52,265
    Year	133,980

Query Results for the Operation: reportFile_with_no_parsing
-----------------------------------------------------

                         Sales Actual Stereo 

                     Qtr1     Qtr2     Qtr3     Qtr4 
                 ======== ======== ======== ======== 

East                7,839    7,933    7,673   10,044 
West               11,633   11,191   11,299   14,018 
South            #Missing #Missing #Missing #Missing 
  Market           19,472   19,124   18,972   24,062 

                      Sales Actual Compact_Disc 

                     Qtr1     Qtr2     Qtr3     Qtr4 
                 ======== ======== ======== ======== 

East               10,293    9,702    9,965   11,792 
West               14,321   14,016   14,328   17,247 
South            #Missing #Missing #Missing #Missing 
  Market           24,614   23,718   24,293   29,039 

                          Sales Actual Audio 

                     Qtr1     Qtr2     Qtr3     Qtr4 
                 ======== ======== ======== ======== 

East               18,132   17,635   17,638   21,836 
West               25,954   25,207   25,627   31,265 
South            #Missing #Missing #Missing #Missing 
  Market           44,086   42,842   43,265   53,101 

