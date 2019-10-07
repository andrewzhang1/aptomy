#!/usr/bin/env python
"""lab17_1_2.py Test for the Money class"""
import unittest
import sys
sys.path.insert(0, '..')
import lab_16_New_Style_Classes.lab16_2 as money_def

class TestMoney(unittest.TestCase):

    def testFormat(self):
        self.assertEqual(str(money_def.Money(-123.21)), "-$123.21")
        self.assertEqual(str(money_def.Money(40.50)), "$40.50")
        self.assertEqual(str(money_def.Money(-1001.011)), "-$1,001.01")
        self.assertEqual(str(money_def.Money(123456789.999)),
                         "$123,456,790.00")
        self.assertEqual(str(money_def.Money(.10)), "$0.10")
        self.assertEqual(str(money_def.Money(.01)), "$0.01")
        self.assertEqual(str(money_def.Money(.055)), "$0.06")

    def testAdd(self):
        self.assertAlmostEqual(money_def.Money(10) + money_def.Money(20),
                               money_def.Money(30))
    def testRepr(self):
        self.assertAlmostEqual(eval(
            'money_def.' + repr(money_def.Money(44.123))), 
                               money_def.Money(44.123))

    def testSub(self):
        self.assertAlmostEqual(money_def.Money('-11.111000'),
                               money_def.Money('-11.111000'))
        self.assertAlmostEqual(
            money_def.Money(44.333) - money_def.Money(55.444), 
            money_def.Money(-11.111))

    def testNeg(self):
        self.assertAlmostEqual(-money_def.Money(10.00),
                               money_def.Money(-10.00))
    def testMult(self):
        self.assertAlmostEqual(2 * money_def.Money(-11.11),
                               money_def.Money(-22.22))
        self.assertAlmostEqual(money_def.Money(-22.22),
                               money_def.Money(11.11) * -2)
    def testDiv(self):
        self.assertAlmostEqual((money_def.Money(44.44))/4,
                               money_def.Money(11.11))

if __name__ == '__main__':
    unittest.main()
"""$ lab17_1_2.py
.......
----------------------------------------------------------------------
Ran 7 tests in 0.003s

OK
$ """
