#!/usr/bin/env python
"""Demonstrates input."""

answer = raw_input('What is your favorite number? ') 
print 'You like', answer, '?'
print 'You really like ' + answer + '?'  
number = int(answer)
if number < 10:
    print number, 'is small.'  
elif number >= 1000:           
    print number, 'is big.'    
else:                          
    print number, 'is medium.' 
                               
print 'But you like ' + str(number) + '!' 
"""                            
$ get_input.py                 
What is your favorite number? 8
You like 8 ?                     <-  space before the '?'!
You really like 8?
8 is small.
But you like 8!
$
Notes:

int(x)   -> converts to integer
str(x)   -> converts to string
float(x) -> converts to float

$ get_input.py
What is your favorite number? x
You like x ?
You really like x?
Traceback (most recent call last):
  File "get_input.py", line 7, in ?
    number = int(answer)
ValueError: invalid literal for int(): x
$ 

"""
