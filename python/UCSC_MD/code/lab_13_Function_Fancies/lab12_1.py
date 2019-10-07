#!/usr/bin/env python
"""soccer_team.py with getattr and setattr, as much as possible."""
import sys 
from soccer_team import * 

this_module = sys.modules[__name__]

def ProcessTeam(stream):
    global positions
    positions = []
    for line in stream:
        line = line.strip()
        if not line:
            continue
        if line.endswith(':'):
            position = line[:-1]
            setattr(this_module, position, [])
            positions += [position]
            continue
        details = line.split(' ', 1)
        setattr(this_module, position,
                getattr(this_module, position) + [details])
        print 'Yeh %s #%s ' % (details[1], details[0]) +\
              eval("Notify%s()" % position)
    return stream.name, positions

def PrintTeam(team_name, positions):
    print team_name + ':'
    for each in positions:
        print '  %s:' % each
        for player in sorted(getattr(this_module, each)):
            print '    ' + ': '.join(player)
    
if __name__ == '__main__':
    main()

""" Same output as soccer_team.py"""
