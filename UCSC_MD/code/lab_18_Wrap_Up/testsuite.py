#!/usr/bin/env python
"""Demonstration of a test suite."""
import unittest   
import lab17_1_1 as clock_test_def
import lab17_1_2 as money_test_def

Clock_suite = clock_test_def.ClockTestSuite()
Money_suite = unittest.makeSuite(money_test_def.TestMoney, 'test')

all_test_suites = unittest.TestSuite((Clock_suite, Money_suite))

unittest.TextTestRunner().run(all_test_suites)

"""
$ testsuite.py
.........
----------------------------------------------------------------------
Ran 9 tests in 10.215s

OK

$
"""

