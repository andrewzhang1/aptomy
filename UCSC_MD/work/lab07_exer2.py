

import lab07_exer1


while True:
    string = raw_input('Input a string: ')
    if string:
        break
    else:
        print 'Input must not be null'

print lab07_exer1.Keypad(string)


"""
>>> 
=========== RESTART: C:\Users\E1HL\Python\exercises\lab07_exer2.py ===========
Input a string: this is a test
8447 47 2 8378
>>> 
"""
