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


Report Output for: {TabDelim} <Column (Scenario, Year) <Row (Market, Product) <Ichild Market <Ichild Product !
----------------------------------------------------------------------------
		Scenario	Year	Measures	
East	100	12,656
 	200	2,534
 	300	2,627
 	400	6,344
 	Diet	2,408
 	  Product	24,161
West	100	3,549
 	200	9,727
 	300	10,731
 	400	5,854
 	Diet	8,087
 	  Product	29,861
South	100	4,773
 	200	6,115
 	300	2,350
 	400	#Missing
 	Diet	4,912
 	  Product	13,238
Central	100	9,490
 	200	9,578
 	300	10,091
 	400	9,103
 	Diet	13,419
 	  Product	38,262
  Market	100	30,468
 	200	27,954
 	300	25,799
 	400	21,301
 	Diet	28,826
 	  Product	105,522



Listing Dimensions 
----------------
Year,Measures,Product,Market,Scenario,Caffeinated,Ounces,Pkg Type,Population,Intro Date,Attribute Calculations
DimName: Year, DimNo: 1
DimName: Measures, DimNo: 2

Default calc script: CALC ALL;
Alias Table Names: Default
,Long Names

Query members: "<ALLINSAMEDIM Year"
Jan	Feb	Mar	Qtr1	Apr	May	Jun	Qtr2	Jul	Aug	Sep	Qtr3	Oct	Nov	Dec	Qtr4	Year

Getting associated attributes for 100-10...
Attr mbr: Caffeinated_True, Attr dim: Caffeinated, Type: boolean, Value: true
Attr mbr: Ounces_12, Attr dim: Ounces, Type: double, Value: 12.0
Attr mbr: Can, Attr dim: Pkg Type, Type: string, Value: Can
Attr mbr: Intro Date_03-25-1996, Attr dim: Intro Date, Type: datetime, Value: 827712000

OLAP Agent log file size: 157294
OLAP App (apjvdse) log file size: 0
Calc functions: <list>
<group name="Boolean">
  <function>
    <name><![CDATA[@ISACCTYPE]]></name>
    <syntax>
       <![CDATA[@ISACCTYPE(tag)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member has the associated accounts tag]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISANCEST]]></name>
    <syntax>
       <![CDATA[@ISANCEST(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is an ancestor of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISATTRIBUTE]]></name>
    <syntax>
       <![CDATA[@ISATTRIBUTE(attMbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member has the attribute mapping of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISCHILD]]></name>
    <syntax>
       <![CDATA[@ISCHILD(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is a child of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISDESC]]></name>
    <syntax>
       <![CDATA[@ISDESC(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is a descendant of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISGEN]]></name>
    <syntax>
       <![CDATA[@ISGEN(dimName, genName | genNum)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member of the specified dimension is in the specified generation]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISIANCEST]]></name>
    <syntax>
       <![CDATA[@ISIANCEST(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is the specified member or an ancestor of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISICHILD]]></name>
    <syntax>
       <![CDATA[@ISICHILD(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is the specified member or a child of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISIDESC]]></name>
    <syntax>
       <![CDATA[@ISIDESC(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is the specified member or a descendant of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISIPARENT]]></name>
    <syntax>
       <![CDATA[@ISIPARENT(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is the parent of the specified member of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISISIBLING]]></name>
    <syntax>
       <![CDATA[@ISISIBLING(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is the specified member or a sibling of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISLEV]]></name>
    <syntax>
       <![CDATA[@ISLEV(dimName, levName | levNum)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member of the specified dimension is in the specified level]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISMBR]]></name>
    <syntax>
       <![CDATA[@ISMBR(mbrName | rangeList | mbrList)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member matches any one of the specified members]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISMBRWITHATTR]]></name>
    <syntax>
       <![CDATA[@ISMBRWITHATTR(dimName, "operator", value)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current base member is associated with an attribute that satisfies the conditions you specify]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISPARENT]]></name>
    <syntax>
       <![CDATA[@ISPARENT(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is the parent of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISSAMEGEN]]></name>
    <syntax>
       <![CDATA[@ISSAMEGEN(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is the same generation as the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISSAMELEV]]></name>
    <syntax>
       <![CDATA[@ISSAMELEV(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is the same level as the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISSIBLING]]></name>
    <syntax>
       <![CDATA[@ISSIBLING(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the current member is a sibling of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISUDA]]></name>
    <syntax>
       <![CDATA[@ISUDA(dimName, UDAStr)]]>
    </syntax>
    <comment>
       <![CDATA[returns TRUE if the specified user-defined attribute (UDA) exists for the current member of the specified dimension at the time of the calculation]]>
    </comment>
  </function>
</group>
<group name="Relationship Functions">
  <function>
    <name><![CDATA[@ANCESTVAL]]></name>
    <syntax>
       <![CDATA[@ANCESTVAL (dimName, genLevNum [, mbrName])]]>
    </syntax>
    <comment>
       <![CDATA[returns the ancestor values of a specified member combination]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ATTRIBUTEBVAL]]></name>
    <syntax>
       <![CDATA[@ATTRIBUTEBVAL(attDimName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the boolean value that is associated with a level 0 attribute member from the specified Boolean attribute dimension, for the current member being calculated]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ATTRIBUTESVAL]]></name>
    <syntax>
       <![CDATA[@ATTRIBUTESVAL(attDimName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the string value that is associated with a level 0 attribute member from the specified String attribute dimension, for the current member being calculated]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ATTRIBUTEVAL]]></name>
    <syntax>
       <![CDATA[@ATTRIBUTEVAL(attDimName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the numeric value that is associated with a level 0 attribute member from the specified numeric, Boolean, or date attribute dimension, for the current member being calculated]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@CURGEN]]></name>
    <syntax>
       <![CDATA[@CURGEN(dimName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the generation number of the current member combination for the specified dimension]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@CURLEV]]></name>
    <syntax>
       <![CDATA[@CURLEV(dimName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the level number of the current member combination for the specified dimension]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@GEN]]></name>
    <syntax>
       <![CDATA[@GEN(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the generation number of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@LEV]]></name>
    <syntax>
       <![CDATA[@LEV(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the level number of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MDANCESTVAL]]></name>
    <syntax>
       <![CDATA[@MDANCESTVAL(dimCount, dimName1, genLevNum1 ... dimNameX, genLevNumX [,mbrName])]]>
    </syntax>
    <comment>
       <![CDATA[returns ancestor-level data from multiple dimensions based on the current member being calculated]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MDPARENTVAL]]></name>
    <syntax>
       <![CDATA[@MDPARENTVAL(numDim, dimName1, ... dimNameX [,mbrName])]]>
    </syntax>
    <comment>
       <![CDATA[returns parent-level data from multiple dimensions based on the current member being calculated]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@PARENTVAL]]></name>
    <syntax>
       <![CDATA[@PARENTVAL(dimName [, mbrName])]]>
    </syntax>
    <comment>
       <![CDATA[returns the parent values of the member being calculated in the specified dimension]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SANCESTVAL]]></name>
    <syntax>
       <![CDATA[@SANCESTVAL(rootMbr,genLevNum [, mbrName])]]>
    </syntax>
    <comment>
       <![CDATA[returns ancestor-level data based on the shared ancestor value of the current member being calculated]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SPARENTVAL]]></name>
    <syntax>
       <![CDATA[@SPARENTVAL(RootMbr [, mbrName])]]>
    </syntax>
    <comment>
       <![CDATA[returns parent-level data based on the shared parent value of the current member being calculated]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@XREF]]></name>
    <syntax>
       <![CDATA[@XREF(locationAlias [, mbrList])]]>
    </syntax>
    <comment>
       <![CDATA[allows a calculation taking place in one Hyperion Essbase database to incorporate values from a different, possibly remote database]]>
    </comment>
  </function>
</group>
<group name="Operators">
  <function>
    <name><![CDATA[%]]></name>
    <syntax>
       <![CDATA[%]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[*]]></name>
    <syntax>
       <![CDATA[*]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[+]]></name>
    <syntax>
       <![CDATA[+]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[-]]></name>
    <syntax>
       <![CDATA[-]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[->]]></name>
    <syntax>
       <![CDATA[->]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[/]]></name>
    <syntax>
       <![CDATA[/]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[:]]></name>
    <syntax>
       <![CDATA[:]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[::]]></name>
    <syntax>
       <![CDATA[::]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[<]]></name>
    <syntax>
       <![CDATA[<]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[<=]]></name>
    <syntax>
       <![CDATA[<=]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[<>]]></name>
    <syntax>
       <![CDATA[<>]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[==]]></name>
    <syntax>
       <![CDATA[==]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[>]]></name>
    <syntax>
       <![CDATA[>]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[>=]]></name>
    <syntax>
       <![CDATA[>=]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[AND]]></name>
    <syntax>
       <![CDATA[AND]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[NOT]]></name>
    <syntax>
       <![CDATA[NOT]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[OR]]></name>
    <syntax>
       <![CDATA[OR]]>
    </syntax>
    <comment>
       <![CDATA[]]>
    </comment>
  </function>
</group>
<group name="Math">
  <function>
    <name><![CDATA[@ABS]]></name>
    <syntax>
       <![CDATA[@ABS(expression)]]>
    </syntax>
    <comment>
       <![CDATA[returns the absolute value of expression]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@AVG]]></name>
    <syntax>
       <![CDATA[@AVG(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList)]]>
    </syntax>
    <comment>
       <![CDATA[returns the average of all values in expList]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@EXP]]></name>
    <syntax>
       <![CDATA[@EXP(expression)]]>
    </syntax>
    <comment>
       <![CDATA[returns the exponent of the expression]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@FACTORIAL]]></name>
    <syntax>
       <![CDATA[@FACTORIAL(expression)]]>
    </syntax>
    <comment>
       <![CDATA[returns the factorial of expression]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@INT]]></name>
    <syntax>
       <![CDATA[@INT(expression)]]>
    </syntax>
    <comment>
       <![CDATA[returns the next lowest integer value of expression]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@LOG]]></name>
    <syntax>
       <![CDATA[@LOG(a [, b])]]>
    </syntax>
    <comment>
       <![CDATA[computes b-based or 10-based logarithm of a]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@LOG10]]></name>
    <syntax>
       <![CDATA[LOG10(expression)]]>
    </syntax>
    <comment>
       <![CDATA[returns the 10-based logarithm of the expression]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MAX]]></name>
    <syntax>
       <![CDATA[@MAX(expList)]]>
    </syntax>
    <comment>
       <![CDATA[returns the maximum value among the results of the expressions]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MAXS]]></name>
    <syntax>
       <![CDATA[@MAXS(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList)]]>
    </syntax>
    <comment>
       <![CDATA[returns the maximum value among the results of the expressions]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MIN]]></name>
    <syntax>
       <![CDATA[@MIN(expList)]]>
    </syntax>
    <comment>
       <![CDATA[returns the minimum value among the results of the expressions]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MINS]]></name>
    <syntax>
       <![CDATA[@MINS(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList)]]>
    </syntax>
    <comment>
       <![CDATA[returns the minimum value among the results of the expressions]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MOD]]></name>
    <syntax>
       <![CDATA[@MOD(mbrName1, mbrName2)]]>
    </syntax>
    <comment>
       <![CDATA[calculates the modulus of a division operation]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@POWER]]></name>
    <syntax>
       <![CDATA[@POWER(expression,power)]]>
    </syntax>
    <comment>
       <![CDATA[returns the value of the specified expression raised to power]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@REMAINDER]]></name>
    <syntax>
       <![CDATA[@REMAINDER(expression)]]>
    </syntax>
    <comment>
       <![CDATA[returns the remainder value of expression]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ROUND]]></name>
    <syntax>
       <![CDATA[@ROUND(expression, numDigits)]]>
    </syntax>
    <comment>
       <![CDATA[rounds expression to numDigits]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SUM]]></name>
    <syntax>
       <![CDATA[@SUM(expList)]]>
    </syntax>
    <comment>
       <![CDATA[returns the summation of all the values in expList]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SUMRANGE]]></name>
    <syntax>
       <![CDATA[@SUMRANGE(mbrName [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the summation of all the values of the specified member (mbrName) across the specified range (rangeList)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@TRUNCATE]]></name>
    <syntax>
       <![CDATA[@TRUNCATE(expression)]]>
    </syntax>
    <comment>
       <![CDATA[removes the fractional part of expression, returning the integer]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@VAR]]></name>
    <syntax>
       <![CDATA[@VAR(mbrName1, mbrName2)]]>
    </syntax>
    <comment>
       <![CDATA[calculates the variance (difference) between two members]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@VARPER]]></name>
    <syntax>
       <![CDATA[@VARPER(mbrName1, mbrName2)]]>
    </syntax>
    <comment>
       <![CDATA[calculates the percent variance (difference) between two members]]>
    </comment>
  </function>
</group>
<group name="Member Set">
  <function>
    <name><![CDATA[@ALLANCESTORS]]></name>
    <syntax>
       <![CDATA[@ALLANCESTORS(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns all ancestors of the specified member, including ancestors of any occurrences of the specified member as a shared member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ANCEST]]></name>
    <syntax>
       <![CDATA[@ANCEST(dimName, genLevNum [, mbrName])]]>
    </syntax>
    <comment>
       <![CDATA[returns the ancestor at the specified generation or level of the current member being calculated in the specified dimension; if you specify the optional mbrName, that ancestor is combined with the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ANCESTORS]]></name>
    <syntax>
       <![CDATA[@ANCESTORS(mbrName [, genLevNum | genLevName])]]>
    </syntax>
    <comment>
       <![CDATA[returns all ancestors of the specified member (mbrName) or those up to a specified generation or level]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ATTRIBUTE]]></name>
    <syntax>
       <![CDATA[@ATTRIBUTE(attMbrName)]]>
    </syntax>
    <comment>
       <![CDATA[generates a list of all base members that are associated with the specified attribute member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@CHILDREN]]></name>
    <syntax>
       <![CDATA[@CHILDREN(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns all children of the specified member, excluding the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@CURRMBR]]></name>
    <syntax>
       <![CDATA[@CURRMBR(dimName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the member that is currently being calculated in the specified dimension (dimName)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@DESCENDANTS]]></name>
    <syntax>
       <![CDATA[@DESCENDANTS(mbrName [, genLevNum | genLevName])]]>
    </syntax>
    <comment>
       <![CDATA[returns all descendants of the specified member, or those down to the specified generation or level]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@GENMBRS]]></name>
    <syntax>
       <![CDATA[@GENMBRS(dimName, genName | genNum)]]>
    </syntax>
    <comment>
       <![CDATA[returns all members with the specified generation number or generation name in the specified dimension]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@IALLANCESTORS]]></name>
    <syntax>
       <![CDATA[@IALLANCESTORS(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the specified member and all the ancestors of that member, including ancestors of any occurrences of the specified member as a shared member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@IANCESTORS]]></name>
    <syntax>
       <![CDATA[@IANCESTORS(mbrName [, genLevNum | genLevName])]]>
    </syntax>
    <comment>
       <![CDATA[returns the specified member and either all ancestors of the specified member or all ancestors up to the specified generation or level]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ICHILDREN]]></name>
    <syntax>
       <![CDATA[@ICHILDREN(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the specified member and all of its children]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@IDESCENDANTS]]></name>
    <syntax>
       <![CDATA[@IDESCENDANTS(mbrName[, genLevNum | genLevName])]]>
    </syntax>
    <comment>
       <![CDATA[returns the specified member and either all descendants of the specified member or all descendants down to a specified generation or level]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ILSIBLINGS]]></name>
    <syntax>
       <![CDATA[@ILSIBLINGS(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the specified member and all of the left siblings of the member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@IRDESCENDANTS]]></name>
    <syntax>
       <![CDATA[@IRDESCENDANTS(mbrName[, genLevNum | genLevName])]]>
    </syntax>
    <comment>
       <![CDATA[returns the specified member and either all descendants of the specified member or all descendants down to a specified generation or level traversing shared members recursively]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@IRSIBLINGS]]></name>
    <syntax>
       <![CDATA[@IRSIBLINGS(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the specified member and all of the right siblings of the member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@ISIBLINGS]]></name>
    <syntax>
       <![CDATA[@ISIBLINGS(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the specified member and all siblings of that member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@LEVMBRS]]></name>
    <syntax>
       <![CDATA[@LEVMBRS(dimName, levName | levNum)]]>
    </syntax>
    <comment>
       <![CDATA[returns all members with the specified level number or level name in the specified dimension]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@LSIBLINGS]]></name>
    <syntax>
       <![CDATA[@LSIBLINGS(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the left siblings of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MATCH]]></name>
    <syntax>
       <![CDATA[@MATCH(mbrName|genName|levName, "pattern")]]>
    </syntax>
    <comment>
       <![CDATA[performs wildcard member selections]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MERGE]]></name>
    <syntax>
       <![CDATA[@MERGE(list1, list2)]]>
    </syntax>
    <comment>
       <![CDATA[merges two member lists]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@PARENT]]></name>
    <syntax>
       <![CDATA[@PARENT(dimName [, mbrName])]]>
    </syntax>
    <comment>
       <![CDATA[returns the parent of the current member being calculated in the specified dimension; if you specify the optional mbrName, that parent is combined with the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@RANGE]]></name>
    <syntax>
       <![CDATA[@RANGE(mbrName [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns a member list that crosses the specified member from one dimension (mbrName) with the specified member range from another dimension (rangeList)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@RDESCENDANTS]]></name>
    <syntax>
       <![CDATA[@RDESCENDANTS(mbrName [, genLevNum | genLevName])]]>
    </syntax>
    <comment>
       <![CDATA[returns all descendants of the specified member, or those down to the specified generation or level traversing shared members recursively]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@RELATIVE]]></name>
    <syntax>
       <![CDATA[@RELATIVE(mbrName, genLevNum | genLevName)]]>
    </syntax>
    <comment>
       <![CDATA[returns all members at the specified generation or level that are above or below the specified member in the database outline]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@REMOVE]]></name>
    <syntax>
       <![CDATA[@REMOVE(list1, list2)]]>
    </syntax>
    <comment>
       <![CDATA[removes values or members in one list from another list]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@RSIBLINGS]]></name>
    <syntax>
       <![CDATA[@RSIBLINGS(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns the right siblings of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SHARE]]></name>
    <syntax>
       <![CDATA[@SHARE(mbrList)]]>
    </syntax>
    <comment>
       <![CDATA[returns all of the shared members of a list of members]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SIBLINGS]]></name>
    <syntax>
       <![CDATA[@SIBLINGS(mbrName)]]>
    </syntax>
    <comment>
       <![CDATA[returns all siblings of the specified member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SXRANGE]]></name>
    <syntax>
       <![CDATA[@SXRANGE(mbrName [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns a member list that crosses the specified member from one dimension (mbrName) with the specified member range from another dimension (rangeList)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@UDA]]></name>
    <syntax>
       <![CDATA[@UDA(dimName, uda)]]>
    </syntax>
    <comment>
       <![CDATA[returns members based on a common attribute, which you have defined as a user-defined attribute]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@WITHATTR]]></name>
    <syntax>
       <![CDATA[@WITHATTR(dimName, "operator", value)]]>
    </syntax>
    <comment>
       <![CDATA[returns all base members that are associated with an attribute that satisfies the conditions you specify]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@WITHATTRSCA]]></name>
    <syntax>
       <![CDATA[@WITHATTR(dimName, "operator", value)]]>
    </syntax>
    <comment>
       <![CDATA[returns all base members that are associated with an attribute that satisfies the conditions you specify]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@_WITHATTR]]></name>
    <syntax>
       <![CDATA[@WITHATTR(dimName, "operator", value)]]>
    </syntax>
    <comment>
       <![CDATA[returns all base members that are associated with an attribute that satisfies the conditions you specify]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@_WITHATTRSCA]]></name>
    <syntax>
       <![CDATA[@WITHATTRSCA(dimName, "operator", value)]]>
    </syntax>
    <comment>
       <![CDATA[returns all base members that are associated with an attribute that satisfies the conditions you specify]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@__CURRMBRRANGE]]></name>
    <syntax>
       <![CDATA[(null)]]>
    </syntax>
    <comment>
       <![CDATA[(null)]]>
    </comment>
  </function>
</group>
<group name="Range (Financial)">
  <function>
    <name><![CDATA[@ACCUM]]></name>
    <syntax>
       <![CDATA[@ACCUM(mbrName [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[accumulates the values of mbrName within rangeList, up to the current member in the dimension of which rangeList is a part]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@AVGRANGE]]></name>
    <syntax>
       <![CDATA[@AVGRANGE(mbrName [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the average of all the values of the specified member (mbrName) across the specified range (rangeList)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@AVGRANGE1]]></name>
    <syntax>
       <![CDATA[@AVGRANGE(mbrName [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the average of all the values of the specified member (mbrName) across the specified range (rangeList)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@AVGRANGE2]]></name>
    <syntax>
       <![CDATA[@AVGRANGE(mbrName [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the average of all the values of the specified member (mbrName) across the specified range (rangeList)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@COMPOUND]]></name>
    <syntax>
       <![CDATA[@COMPOUND(balanceMbr, rateMbrConst [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[compiles the proceeds of a compound interest calculation]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@COMPOUNDGROWTH]]></name>
    <syntax>
       <![CDATA[@COMPOUNDGROWTH(principalMbr, rateMbrConst [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[calculates a series of values that represent a compound growth of the first nonzero value in the specified member across the specified range of members]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@CURRMBRRANGE]]></name>
    <syntax>
       <![CDATA[@CURRMBRRANGE(dimName, {GEN|LEV}, genLevNum, [startOffset], [endOffset])]]>
    </syntax>
    <comment>
       <![CDATA[generates a member list that is based on the relative position of the current member being calculated]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@DECLINE]]></name>
    <syntax>
       <![CDATA[@DECLINE(costMbr, salvageMbrConst, lifeMbrConst, factorMbrConst [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[calculates the depreciation of an asset for the specified period using the declining balance method]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@DISCOUNT]]></name>
    <syntax>
       <![CDATA[@DISCOUNT (cashMbr, rateMbrConst [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[calculates a value discounted by the specified rate, from the first period of the range to the period in which the amount to discount is found]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@GROWTH]]></name>
    <syntax>
       <![CDATA[@GROWTH(principalMbr, rateMbrConst [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[calculates a series of values that represent a linear growth of the first nonzero value encountered in principalMbr across the specified rangeList]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@INTEREST]]></name>
    <syntax>
       <![CDATA[@INTEREST(balanceMbr, creditrateMbrConst, borrowrateMbrConst [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[calculates the simple interest in balanceMbr at the rate specified by creditrateMbrConst if the value specified by balanceMbr is positive, or at the rate specified by borrowrateMbrConst if balanceMbr is negative]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@IRR]]></name>
    <syntax>
       <![CDATA[@IRR(cashflowMbr, discountFlag[, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[calculates the Internal Rate of Return on a cash flow that must contain at least one investment (negative) and one income (positive) value]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MAXRANGE]]></name>
    <syntax>
       <![CDATA[@MAXRANGE (mbrName [ , rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the maximum value of the specified member across the specified range of members]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MAXSRANGE]]></name>
    <syntax>
       <![CDATA[@MAXSRANGE(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, mbrName [ , rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the maximum value of the specified member across the specified range of members]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MDSHIFT]]></name>
    <syntax>
       <![CDATA[@MDSHIFT (mbrName, shiftCnt1, dimName1, [range1|(range1)], ... shiftCntX, dimNameX, [rangeX|(rangeX)])]]>
    </syntax>
    <comment>
       <![CDATA[shifts a series of data values across multiple dimension ranges]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MINRANGE]]></name>
    <syntax>
       <![CDATA[@MINRANGE (mbrName [ , rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the minimum value of the specified member across the specified range of members]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MINSRANGE]]></name>
    <syntax>
       <![CDATA[@MINSRANGE(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, mbrName [ , rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the minimum value of the specified member across the specified range of members]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@NEXT]]></name>
    <syntax>
       <![CDATA[@NEXT(mbrName [, n, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the nth cell value in the sequence rangeList from mbrName, retaining all other members identical to the current member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@NEXTS]]></name>
    <syntax>
       <![CDATA[@NEXTS(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, mbrName [, n, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the nth cell value in the sequence rangeList from mbrName,removing zero or missing values according to the first parameter; all other dimensions assume the same members as the current member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@NPV]]></name>
    <syntax>
       <![CDATA[@NPV(cashflowMbr, rateMbrConst, discountFlag [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[calculates the Net Present Value of an investment based on the series of payments (negative values) and income (positive values)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@PRIOR]]></name>
    <syntax>
       <![CDATA[@PRIOR(mbrName [, n, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the nth previous cell member from mbrName in rangeList; all other dimensions assume the same members as the current member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@PRIORS]]></name>
    <syntax>
       <![CDATA[@PRIORS(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, mbrName [, n, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the nth previous cell member from mbrName in rangeList after removing zero or missing values according to the first parameter; all other dimensions assume the same members as the current member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@PTD]]></name>
    <syntax>
       <![CDATA[@PTD(timePeriodList)]]>
    </syntax>
    <comment>
       <![CDATA[calculates the period-to-date values of members in the dimension tagged as Time]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SHIFT]]></name>
    <syntax>
       <![CDATA[@SHIFT(mbrName [,n, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the nth cell value in the sequence rangeList from mbrName, retaining all other members identical to the current member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SHIFTMINUS]]></name>
    <syntax>
       <![CDATA[@SHIFTMINUS(minusMbrName, mbrName [,n, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the nth cell value in the sequence rangeList from mbrName, retaining all other members identical to the current member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SHIFTPLUS]]></name>
    <syntax>
       <![CDATA[@SHIFTPLUS(plusMbrName, mbrName [,n, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[returns the nth cell value in the sequence rangeList from mbrName, retaining all other members identical to the current member]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SLN]]></name>
    <syntax>
       <![CDATA[@SLN(costMbr, salvageMbrConst, lifeMbrConst [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[calculates the amount per period that an asset in the current period may be depreciated, across a range of periods; the depreciation method used is straight-line depreciation]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SYD]]></name>
    <syntax>
       <![CDATA[@SYD(costMbr, salvageMbrConst, lifeMbrConst [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[calculates the amount per period that an asset in the current period may be depreciated, across a range of periods; the depreciation method used is sum of the year's digits]]>
    </comment>
  </function>
</group>
<group name="Allocation">
  <function>
    <name><![CDATA[@ALLOCATE]]></name>
    <syntax>
       <![CDATA[@ALLOCATE (amount, allocationRange, basisMbr, [roundMbr], method [, methodParams] [, round [, numDigits][, roundErr]])]]>
    </syntax>
    <comment>
       <![CDATA[allocates values from a member, from a cross-dimensional member, or from a value across a member list within the same dimension; the allocation is based on a variety of criteria]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MDALLOCATE]]></name>
    <syntax>
       <![CDATA[@MDALLOCATE (amount, Ndim, allocationRange1 ... allocationRangeN, basisMbr, [roundMbr], method [, methodParams] [, round [, numDigits][, roundErr]])]]>
    </syntax>
    <comment>
       <![CDATA[allocates values from a member, from a cross-dimensional member, or from a value across multiple dimensions; the allocation is based on a variety of criteria]]>
    </comment>
  </function>
</group>
<group name="Forecasting">
  <function>
    <name><![CDATA[@MOVAVG]]></name>
    <syntax>
       <![CDATA[@MOVAVG(mbrName [, n [, rangeList]])]]>
    </syntax>
    <comment>
       <![CDATA[applies a moving n-term average (mean) to an input data set]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MOVMAX]]></name>
    <syntax>
       <![CDATA[@MOVMAX(mbrName [, n [, rangeList]])]]>
    </syntax>
    <comment>
       <![CDATA[applies a moving n-term maximum (highest number) to an input data set]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MOVMED]]></name>
    <syntax>
       <![CDATA[@MOVMED (mbrName [, n [, rangeList]])]]>
    </syntax>
    <comment>
       <![CDATA[applies a moving n-term median (middle number) to an input data set]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MOVMIN]]></name>
    <syntax>
       <![CDATA[@MOVMIN(mbrName [, n [, rangeList]])]]>
    </syntax>
    <comment>
       <![CDATA[applies a moving n-term minimum (lowest number) to an input data set]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MOVSUM]]></name>
    <syntax>
       <![CDATA[@MOVSUM(mbrName [, n [, rangeList]])]]>
    </syntax>
    <comment>
       <![CDATA[applies a moving n-term sum to an input data set]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MOVSUMX]]></name>
    <syntax>
       <![CDATA[@MOVSUMX(COPYFORWARD | TRAILMISSING | TRAILSUM, mbrName [, n [, rangeList]])]]>
    </syntax>
    <comment>
       <![CDATA[applies a moving n-term sum to an input data set]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SPLINE]]></name>
    <syntax>
       <![CDATA[@SPLINE (YmbrName [, s [, XmbrName [, rangeList]]])]]>
    </syntax>
    <comment>
       <![CDATA[applies a smoothing spline to a set of data points]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@TREND]]></name>
    <syntax>
       <![CDATA[@TREND (Ylist, [Xlist], [weightList], [errorList], [XforecastList], YforecastList, method[, method parameters] [, Xfilter1 [, parameters]] [, XfilterN [, parameters]][, Yfilter1 [, parameters]] [, YfilterN [, parameters]])]]>
    </syntax>
    <comment>
       <![CDATA[calculates future values based on curve-fitting to historical values]]>
    </comment>
  </function>
</group>
<group name="Statistical">
  <function>
    <name><![CDATA[@CORRELATION]]></name>
    <syntax>
       <![CDATA[@CORRELATION (SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList1, expList2)]]>
    </syntax>
    <comment>
       <![CDATA[returns the correlation coefficient between two parallel data sets (expList1 and expList2)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@COUNT]]></name>
    <syntax>
       <![CDATA[@COUNT(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList)]]>
    </syntax>
    <comment>
       <![CDATA[returns the number of data values in the specified data set (expList)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MEDIAN]]></name>
    <syntax>
       <![CDATA[@MEDIAN(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList)]]>
    </syntax>
    <comment>
       <![CDATA[returns the median (the middle number) of the specified data set (expList)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@MODE]]></name>
    <syntax>
       <![CDATA[@MODE(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList)]]>
    </syntax>
    <comment>
       <![CDATA[returns the mode (the most frequently occurring value) in the specified data set (expList)]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@RANK]]></name>
    <syntax>
       <![CDATA[@RANK(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, value, expList)]]>
    </syntax>
    <comment>
       <![CDATA[returns the rank of the specified members or the specified value among the values in the specified data set]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@STDEV]]></name>
    <syntax>
       <![CDATA[@STDEV(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList)]]>
    </syntax>
    <comment>
       <![CDATA[calculates the standard deviation of the specified data set (expList); the calculation is based upon a sample of a population]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@STDEVP]]></name>
    <syntax>
       <![CDATA[@STDEVP(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList)]]>
    </syntax>
    <comment>
       <![CDATA[calculates the standard deviation of the specified data set (expList); the calculation is based upon the entire population]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@STDEVRANGE]]></name>
    <syntax>
       <![CDATA[@STDEVRANGE(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, mbrName [, rangeList])]]>
    </syntax>
    <comment>
       <![CDATA[calculates the standard deviation of all values of the specified member (mbrName) across the specified data set (rangeList); the calculation is based upon a sample of a population]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@VARIANCE]]></name>
    <syntax>
       <![CDATA[VARIANCE(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList)]]>
    </syntax>
    <comment>
       <![CDATA[calculates the statistical variance of the specified data set (expList); the calculation is based upon a sample of a population]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@VARIANCEP]]></name>
    <syntax>
       <![CDATA[VARIANCE(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList)]]>
    </syntax>
    <comment>
       <![CDATA[calculates the statistical variance of the specified data set (expList); the calculation is based upon the entire population]]>
    </comment>
  </function>
</group>
<group name="Date and Time">
  <function>
    <name><![CDATA[@TODATE]]></name>
    <syntax>
       <![CDATA[@TODATE (formatString, dateString)]]>
    </syntax>
    <comment>
       <![CDATA[converts date strings to numbers that can be used in calculation formulas]]>
    </comment>
  </function>
</group>
<group name="Miscellaneous">
  <function>
    <name><![CDATA[@ALIAS]]></name>
    <syntax>
       <![CDATA[@ALIAS(mbrList)]]>
    </syntax>
    <comment>
       <![CDATA[returns list of member aliases]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@CALCMODE]]></name>
    <syntax>
       <![CDATA[@CALCMODE(BLOCK | CELL | TOPDOWN | BOTTOMUP)]]>
    </syntax>
    <comment>
       <![CDATA[sets calculation mode to block or single cell, top-down or bottom-up]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@CONCATENATE]]></name>
    <syntax>
       <![CDATA[@CONCATENATE(strExp, strExp)]]>
    </syntax>
    <comment>
       <![CDATA[returns concatenation of two strings]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@NAME]]></name>
    <syntax>
       <![CDATA[@NAME(mbrList)]]>
    </syntax>
    <comment>
       <![CDATA[returns list of member names]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SELECT]]></name>
    <syntax>
       <![CDATA[@SELECT(SKIPNONE | SKIPMISSING | SKIPZERO | SKIPBOTH, expList)]]>
    </syntax>
    <comment>
       <![CDATA[removes zero or missing values from expList according to the first parameter]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@SUBSTRING]]></name>
    <syntax>
       <![CDATA[@SUBSTRING(strExp, startPos [ , endPos])]]>
    </syntax>
    <comment>
       <![CDATA[returns substring of the given string]]>
    </comment>
  </function>
  <function>
    <name><![CDATA[@VAL2STR]]></name>
    <syntax>
       <![CDATA[@VAL2STR(mbrName [, format])]]>
    </syntax>
    <comment>
       <![CDATA[returns the string converted from member value]]>
    </comment>
  </function>
</group>

<group name="Custom">
  <function>
    <name><![CDATA[@ESSBASEALERT]]></name>
    <syntax>
       <![CDATA[@ESSBASEALERT(stringArray, stringArray, doubleArray)]]>
    </syntax>
    <comment>
       <![CDATA[Internal]]>
    </comment>
  </function>
</group>

</list>

