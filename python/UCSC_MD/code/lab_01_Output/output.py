#!/usr/bin/env python
"""output.py  Demonstrates 3 ways to delimit strings."""

print 'Hello world'   
#print                 
print 'She said "Hello world"'
print
print "She said 'Hello world'"
print
print """
Little dark woman of my suffering,
with eyes of flying paper,
you say "Yes" to everyone,
but you never say when."""  # end of string started on line 10.
print "here"
"""  # An unlabeled string is a comment.
$ output.py
Hello world

She said "Hello world"

She said 'Hello world'

Little dark woman of my suffering,
with eyes of flying paper,
you say "Yes" to everyone,
but you never say when.

$
----

Raw strings:    
>>> print r"\n"
\n

These come in handy with regular expressions.
"""
