#!/usr/bin/env python
"""primes.py -- Produces a list of prime numbers.
Here, we are only checking the "look" of Python code.
"""
MAX = 100             # Here is a comment.   
                         
print 'primes are: '  # A new line is added by default.
number = 3               
while number < MAX:
    div = 2
    while div * div <= number:
        if number % div == 0:
            break     
        div += 1      
    else:             # Overloaded 'else', loop didn't 'break'.
        print number, # Trailing comma suppresses the new line.
    number += 2       
print                 # This only produces the new line.
   
"""  Notes:

Call on the command line if you are running *NIX.

$ primes.py
primes are: 
3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97

Or, invoke the interpreter:

$ python primes.py
primes are: 
3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97

Or, ask the interpreter to run it and then stay active for
introspection.

$ python -i primes.py
primes are: 
3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
>>> number
101
>>>"""
