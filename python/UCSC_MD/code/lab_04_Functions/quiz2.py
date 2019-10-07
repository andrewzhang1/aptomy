#!/usr/bin/env python
"""Formatted output -- quiz answers"""

print "%4X" % (8 * 16 + 10)
print "%10.3f" % 232.346
print "%-12.2e|" % 2.33e+02
print "%-30s|" % "left"
print "%8.8s|" % "Tamale Pie"
print "%+.2f" % 3.13
"""
$ quiz2.py
  8A
   232.346
2.33e+02   |
left                          |
Tamale P|
+3.13
$
"""
