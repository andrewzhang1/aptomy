

import string
import sys


class UpError( ValueError):
    pass

def UpIt( text):
    for char in text:
        if char in string.uppercase:
            raise UpError, "Input contains upper case: %s" % (char)
    return str.upper( text)

def test( text):
    try:
        print UpIt( text)
    except UpError:
        print "sys.exc_info(): ", sys.exc_info()
        raise
    except Exception:                               # generic Exception yields same output
        print "sys.exc_info(): ", sys.exc_info()
        raise
    else:
        print "That test was ok"
    finally:
        print "End of that test"


if __name__ == '__main__':
    test( 'this is a test')
    print
    test( 'this is Another test')


"""
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab18_exer1.py ===========
THIS IS A TEST
That test was ok
End of that test

sys.exc_info():  (<class '__main__.UpError'>, UpError('Input contains upper case: A',), <traceback object at 0x02BD2DC8>)
End of that test

Traceback (most recent call last):
  File "C:/Users/E1HL/Python/exercises/lab18_exer1.py", line 34, in <module>
    test( 'this is Another test')
  File "C:/Users/E1HL/Python/exercises/lab18_exer1.py", line 18, in test
    print UpIt( text)
  File "C:/Users/E1HL/Python/exercises/lab18_exer1.py", line 13, in UpIt
    raise UpError, "Input contains upper case: %s" % (char)
UpError: Input contains upper case: A
>>> 
"""
