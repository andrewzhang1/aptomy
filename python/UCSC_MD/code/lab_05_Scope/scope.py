#!/usr/bin/env python
""" scope.py  -- Scoping example."""

pies = 1 # global identifier

# alters the local identifier pies, shadows the global identifier
def DoApple():  
   pies = 25 

   print "\nlocal pies in DoApple() is", pies, "after entering DoApple()"
   pies += 1
   print "local pies in DoApple() is", pies, "before exiting DoApple()"

# alters the global identifier pies
def DoBerry():
   global pies

   print "\nglobal pies is", pies, "on entering DoBerry()"
   pies *= 10
   print "global pies is", pies, "on exiting DoBerry()"

def DoCherry():
   print "In DoCherry(), you can access, but not alter the global pies = ",\
   pies

def DoMud():
   
   print "In DoMud(), you can't even access global pies if you try", \
   "to assign into it! \nSee: ", pies
   pies = 999
   
print "global pies is", pies

pies = 7
print "global pies is", pies

DoApple()
DoBerry()
DoApple()
DoBerry()

print "\nglobal pies is", pies

DoCherry()
DoMud()

""" 
global pies is 1
global pies is 7

local pies in DoApple() is 25 after entering DoApple()
local pies in DoApple() is 26 before exiting DoApple()

global pies is 7 on entering DoBerry()
global pies is 70 on exiting DoBerry()

local pies in DoApple() is 25 after entering DoApple()
local pies in DoApple() is 26 before exiting DoApple()

global pies is 70 on entering DoBerry()
global pies is 700 on exiting DoBerry()

global pies is 700
In DoCherry(), you can access, but not alter the global pies =  700
In DoMud(), you can't even access global pies if you try to assign into it! 
See: 
Traceback (most recent call last):
  File "./scope.py", line 44, in <module>
    DoMud()
  File "./scope.py", line 28, in DoMud
    to assign into it! \nSee: ", pies
UnboundLocalError: local identifier 'pies' referenced before assignment

$

"""\end{verbatim} \index{identifier!scope|)} \begin{verbatim}

