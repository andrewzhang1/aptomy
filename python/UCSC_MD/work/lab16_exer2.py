

#import lab_08_Comprehensions.lab08_4 as normalize
import lab08_exer4 as normalize


class Money( float):

    def __str__( self):
#        return normalize.MakeMoneyString( self)
        return normalize.MoneyString( self)

    def __repr__( self):
        return "Money( '%f')" % self

    def __neg__( self):
        return Money( float.__neg__( self))

    def __add__( self, other):
        return Money( float.__add__( self, other))

    def __sub__( self, other):
        return Money( float.__sub__( self, other))

    def __mul__( self, number):
        return Money( float.__mul__( self, number))

    def __div__( self, number):
        return Money( float.__div__( self, number))


if __name__ == '__main__':
    print Money( 123.456)
    print eval( repr( Money( 123.456)))
    print Money(-123.456)
    print Money( 123.456 + 78.90)
    print Money( 123.456 - 78.90)
    print Money( 123.456 * 2)
    print Money( 123.456 / 2)


"""
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab16_exer2.py ===========
$123.46
$123.46
-$123.46
$202.36
$44.56
$246.91
$61.73
>>> 
"""
