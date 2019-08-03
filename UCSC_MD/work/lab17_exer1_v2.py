

"""
This version imports from lab16_exer only Money.
Then within the test, reference to Money is required.

In testRepr, Money(...) returns a string like "Money(...)", so that
            eval( repr( Money(...)))
becomes     eval( Money(...))
and this does not raise "NameError: global name 'Money' is not defined".
"""


from lab16_exer2 import Money

import unittest


class TestMoney( unittest.TestCase):

    def setUp( self):
        pass

    def testStr( self):
        self.assertEqual( str( Money( 123.456)), '$123.46')

    def testRepr( self):
        self.assertEqual( str( eval( repr( Money( 123.456)))), '$123.46')

    def testNeg( self):
        self.assertEqual( str( Money(-123.456)), '-$123.46')

    def testAdd( self):
        self.assertEqual( str( Money( 123.456 + 78.90)), '$202.36')

    def testSub( self):
        self.assertEqual( str( Money( 123.456 - 78.90)), '$44.56')

    def testMul( self):
        self.assertEqual( str( Money( 123.456 * 2)), '$246.91')

    def testDiv( self):
        self.assertEqual( str( Money( 123.456 / 2)), '$61.73')

    def tearDown( self):
        pass


if __name__ == '__main__':
    unittest.main()


"""
>>> 
========= RESTART: C:\Users\E1HL\Python\exercises\lab17_exer1_v2.py =========
.......
----------------------------------------------------------------------
Ran 7 tests in 0.062s

OK
>>> 
"""
