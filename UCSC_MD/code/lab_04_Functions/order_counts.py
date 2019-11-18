#!/usr/bin/env python
"""Order matters."""

def BeatDrum():
    print('boom! boom!')


def StrumGuitar():
    print ('strum. strum.')
    BeatDrum()

#StrumGuitar()
#







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
