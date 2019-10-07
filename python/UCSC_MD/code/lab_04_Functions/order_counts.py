#!/usr/bin/env python
"""Order matters."""

def StrumGuitar():
    print 'strum. strum.'
    BeatDrum()

StrumGuitar()

def BeatDrum():
    print 'boom! boom!'

"""
$ refs.py
strumming StrumGuitar()
Traceback (innermost last):
  File "refs.py", line 8, in ?
    StrumGuitar()
  File "refs.py", line 6, in StrumGuitar
    BeatDrum()
NameError: BeatDrum
$     
"""
