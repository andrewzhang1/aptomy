

import math


def Get_XY( prompt):
    while True:
        x = raw_input( prompt + " (or null to quit): x = ")
        if x:
            try:
                x = float( x)
                break
            except ValueError, eobj:
                print eobj
                print "Please try again"
            except (EOFError, KeyboardInterrupt), eobj:
                print eobj
                return None
        else:
            return None

    while True:
        y = raw_input( prompt + " (or null to quit): y = ")
        if x:
            try:
                y = float( y)
                break
            except ValueError, eobj:
                print eobj
                print "Please try again"
            except (EOFError, KeyboardInterrupt), eobj:
                print eobj
                return None
        else:
            return None

    return (x, y)

def hypotenuse( t):
    return math.sqrt( t[0]**2 + t[1]**2)

def test( prompt):
    try:
        print hypotenuse( Get_XY( prompt))
    except TypeError, eobj:
        print eobj
        print "You quit"


if __name__ == '__main__':
    test( "Enter number")


"""
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab18_exer2.py ===========
Enter number (or null to quit): x = 3
Enter number (or null to quit): y = 4
5.0
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab18_exer2.py ===========
Enter number (or null to quit): x = a
could not convert string to float: a
Please try again
Enter number (or null to quit): x = 3
Enter number (or null to quit): y = 4
5.0
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab18_exer2.py ===========
Enter number (or null to quit): x = 

<Ctrl-D>
Traceback (most recent call last):
  File "C:/Users/E1HL/Python/exercises/lab18_exer2.py", line 50, in <module>
    test( "Enter number")
  File "C:/Users/E1HL/Python/exercises/lab18_exer2.py", line 44, in test
    print hypotenuse( Get_XY( prompt))
  File "C:/Users/E1HL/Python/exercises/lab18_exer2.py", line 8, in Get_XY
    x = raw_input( prompt + " (or null to quit): x = ")
EOFError: EOF when reading a line
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab18_exer2.py ===========
Enter number (or null to quit): x = 

<Ctrl-C>
Traceback (most recent call last):
  File "C:/Users/E1HL/Python/exercises/lab18_exer2.py", line 50, in <module>
    test( "Enter number")
  File "C:/Users/E1HL/Python/exercises/lab18_exer2.py", line 44, in test
    print hypotenuse( Get_XY( prompt))
  File "C:/Users/E1HL/Python/exercises/lab18_exer2.py", line 8, in Get_XY
    x = raw_input( prompt + " (or null to quit): x = ")
  File "C:\Program Files (x86)\Python\Python27\lib\idlelib\PyShell.py", line 1398, in readline
    line = self._line_buffer or self.shell.readline()
KeyboardInterrupt
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab18_exer2.py ===========
Enter number (or null to quit): x =
<Null>
'NoneType' object has no attribute '__getitem__'
You quit
>>> 
"""
    
