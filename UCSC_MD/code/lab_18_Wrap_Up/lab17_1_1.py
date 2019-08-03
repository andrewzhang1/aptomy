#!/usr/bin/env python
"""lab17_1_1.py Unit test for clock_def.py"""
import unittest
import sys
import time
sys.path.insert(0, '..')  
import lab_15_Overriding.lab15 as clock_def

class TestClock(unittest.TestCase):

    test_values = [(hours, minutes) for hours in range(-10, 25) \
                   for minutes in range(-122, 122)]

    def testInitEqual(self):
        now = time.ctime()[11:16]
        self.assertEqual(clock_def.Clock(now), clock_def.Clock())
        self.assertRaises(ValueError, clock_def.Clock, (1, 2, 3))
        for (hours, minutes) in TestClock.test_values:
            clocks = [clock_def.Clock(hours, minutes)]
            clocks += [clock_def.Clock((hours, minutes))]
            clocks += [clock_def.Clock("%d:%02d" % (hours, minutes))]
            clocks += [clock_def.Clock({'hr': hours, 'min': minutes})]
            clocks += [clock_def.Clock(hr=hours, min=minutes)]
            clock_str = str(clocks[0])
            clock_repr = repr(clocks[0])
            clock_mins = clocks[0].MinutesSince12()
            for each in clocks[1:]:
                self.assertTrue(each.min<60 and each.min>=0)
                self.assertTrue(each.hr>=1 and each.hr<13)
                self.assertEqual(str(each), clock_str)
                self.assertEqual(repr(each), clock_repr)
                self.assertEqual(clocks[0], eval("clock_def." + repr(each)))
                self.assertEqual(each.MinutesSince12(), clock_mins)
                self.assertEqual(each, clocks[0])

    def testAddSub(self):
        self.c1 = clock_def.Clock(12, 59)
        for (hours, minutes) in TestClock.test_values:
            c2 = clock_def.Clock(hours, minutes)
            c_sum = self.c1 + c2
            c_diff = self.c1 - c2
            c3 = c_sum + c_diff # should be 2 * self.c1
            c4 = clock_def.Clock(self.c1.hr * 2, self.c1.min * 2)
            self.assertEqual(c3, c4)

class ClockTestSuite(unittest.TestSuite):
    """Ignore this class for now, it is for aggregating tests into a
    test suite."""

    def __init__(self):
        unittest.TestSuite.__init__(self, map(
            TestClock, ("testInitEqual", "testAddSub")))

if __name__ == '__main__':
    unittest.main()

"""
$ lab17_1_1.py
..
----------------------------------------------------------------------
Ran 2 tests in 16.185s

OK
$
"""
