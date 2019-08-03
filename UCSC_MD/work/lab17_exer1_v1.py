

"""
This version imports lab16_exer2 in whole (with alias moneylib).
Then within the tests, reference to moneylib.Money is required.

In testRepr, repr( moneylib.Money(...)) returns a string like "Money(...)", so that
            eval( repr( moneylib.Money(...)))
becomes     eval( Money(...))
and this raises "NameError: global name 'Money' is not defined".

To workaround this, we write
            eval( 'moneylib.' + repr( moneylib.Money(...)))
"""


import lab16_exer2 as moneylib

import unittest


class TestMoney( unittest.TestCase):

    def setUp( self):
        pass

    def testStr( self):
        self.assertEqual( str( moneylib.Money( 123.456)), '$123.46')

    def testRepr( self):
        self.assertEqual( str( eval( 'moneylib.' + repr( moneylib.Money( 123.456)))), '$123.46')

    def testNeg( self):
        self.assertEqual( str( moneylib.Money(-123.456)), '-$123.46')

    def testAdd( self):
        self.assertEqual( str( moneylib.Money( 123.456 + 78.90)), '$202.36')

    def testSub( self):
        self.assertEqual( str( moneylib.Money( 123.456 - 78.90)), '$44.56')

    def testMul( self):
        self.assertEqual( str( moneylib.Money( 123.456 * 2)), '$246.91')

    def testDiv( self):
        self.assertEqual( str( moneylib.Money( 123.456 / 2)), '$61.73')

    def tearDown( self):
        pass


if __name__ == '__main__':
    unittest.main()


"""
>>> 
========= RESTART: C:\Users\E1HL\Python\exercises\lab17_exer1_v1.py =========
.......
----------------------------------------------------------------------
Ran 7 tests in 0.016s

OK
>>> 
"""
