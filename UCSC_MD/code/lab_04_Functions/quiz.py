#!/usr/bin/env python
"""
Quiz 1 (Lab 04)
Reports the user's name and letter grade.
"""

name = raw_input("What's your name: ")
try:
    score = int(raw_input("Score please: "))
except ValueError:
    print "That's not a valid score."
else:
    print name, "your grade is",
    if score >= 90:
        print 'A.'
    elif score >= 80:
        print 'B.'
    elif score >= 70:
        print 'C.'
    elif score >= 60:
        print 'D.'
    else:
        print 'F.'

"""
$ quiz.py
What's your name: Jean
Score please: 92
Jean your grade is A.
$ quiz.py
What's your name: Ann
Score please: A
That's not a valid score.
$
"""
