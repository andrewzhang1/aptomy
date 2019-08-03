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
Performing member selection (Select children of Year):
Name: Qtr1, Desc: , Level Num: 1, Gen Num: 2, Child count: 3, Dim Name: Year, Dim Category: None
Name: Qtr2, Desc: , Level Num: 1, Gen Num: 2, Child count: 3, Dim Name: Year, Dim Category: None
Name: Qtr3, Desc: , Level Num: 1, Gen Num: 2, Child count: 3, Dim Name: Year, Dim Category: None
Name: Qtr4, Desc: , Level Num: 1, Gen Num: 2, Child count: 3, Dim Name: Year, Dim Category: None

Performing member selection (Get count of children of Qtr1):
Count of Qtr1 children: 3

Performing member selection: (@ichild(Product), @ichild(Market))
Name: East
Name: West
Name: South
Name: Market
Name: Audio
Name: Visual
Name: Product

Performing Outline Query (find member Accounts)
Name: Accounts, Desc: , Level Num: 3, Gen Num: 1, Child count: 3, Dim Name: Accounts, Dim Category: Accounts, Alias: null

Opening sample/basic outline...
Shared members for 200-20...
Shared member name: 200-20

Getting associated attributes (for Product)...
Attribute: Caffeinated
Attribute: Ounces
Attribute: Pkg Type
Attribute: Intro Date

Getting Dimension (Market) UDAs...
UDA: Major Market
UDA: Small Market
UDA: New Market
