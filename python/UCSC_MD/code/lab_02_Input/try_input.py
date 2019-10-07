#!/usr/bin/env python
"""Demonstrates catching an exception on error."""

answer = raw_input('What is your favorite number? ')
print 'You like', answer, '?'
print 'You really like ' + answer + '?'
try:                              
    number = int(answer)
except ValueError:
    print answer, 'is not a number!'
else:
    if number < 10:
        print number, 'is small.'
    elif number >= 1000:
        print number, 'is big.'
    else:
        print number, 'is medium.'

    print 'But you like ' + str(number) + '!'
"""
$ try_input.py
What is your favorite number? 44
You like 44 ?
You really like 44?
44 is medium.
But you like 44!
$ try_input.py
What is your favorite number? xx
You like xx ?
You really like xx?
xx is not a number!
$
"""
