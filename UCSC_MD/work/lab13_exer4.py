

"""
"""


import random
import time


def Decorator( fcn):
    """
    Decorator function to report when fcn called, and result of fcn call
    """

    def Wrapper( *argt, **argd):
        result = fcn( *argt, **argd)
        print "%s, %s: %s" % (time.ctime(), fcn.__name__, result)
        return result

    return Wrapper


# old syntax
def Lotto1():
    """
    Randomly select 6 digits from 0 .. 51
    """

    return random.sample( range( 52), 6)

Lotto1 = Decorator( Lotto1)


# syntactic sugar
@Decorator
def Lotto2():
    """
    Randomly select 6 digits from 0 .. 51
    """

    return random.sample( range( 52), 6)


if __name__ == '__main__':
    Lotto1()
    print
    Lotto2()


"""
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab13_exer4.py ===========
Wed Jul 27 15:46:33 2016, Lotto1: [13, 29, 23, 41, 15, 16]

Wed Jul 27 15:46:33 2016, Lotto2: [37, 40, 22, 13, 1, 38]
>>> 
"""
