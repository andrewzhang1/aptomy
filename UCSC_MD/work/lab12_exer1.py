

#!/usr/bin/env python
#"""Processing team data using exec and eval."""
"""Processing team data using setattr and getattr."""


import sys
this_module = sys.modules[__name__]                             # this_module = __main__ module


def NotifyForwards(): 
    return "Go for the goal!" 

def NotifyDefenders():
    return "Block that kick!"

def NotifyMidfielders():
    return "Get that ball!"

def NotifyGoalies():
    return "Guard the goal!"


def ProcessTeam(stream):
    """
    """

    positions = []
    for line in stream:
        line = line.strip()
        if not line:
            continue
        if line.endswith(':'):
            position = line[:-1]
            
#           exec "%s = []" % (position) in globals()
            setattr( this_module, position, [])                 # __main__ implies position in globals()
            
            positions += [position]
            continue
        details = line.split(' ', 1)
        
#        exec "%s += [details]" % (position)
        setattr( this_module, position, getattr( this_module, position) + [details])
        
#        exec "print 'Yeh %s #%s ' + Notify%s()" % (details[1], details[0], position)
        exec "print 'Yeh %s #%s ' + Notify%s()" % (
            getattr( this_module, position)[-1][1],
            getattr( this_module, position)[-1][0],
            position
            )

    return stream.name, positions


def PrintTeam(team_name, positions):
    """
    """

    print '\n%s:' % team_name 
    for each in positions:
        print '  %s:' % each

#        for player in sorted(eval(each)):
        for player in sorted( getattr( this_module, each)):     # from globals()

            print '    ' + ': '.join(player)


def main(team_name = "Bees"):
    team_name, positions = ProcessTeam(open("lab_12_Dynamic_Code\\" + team_name))
    PrintTeam(team_name, positions)


if __name__ == '__main__':
    main()


"""
>>> 
= RESTART: C:\Users\E1HL\Python\exercises\lab_12_Dynamic_Code\soccer_team.py =
Yeh Bruce Penge #7 Go for the goal!
Yeh Maureen Mezzabo #1 Go for the goal!
Yeh Samantha Smith #8 Go for the goal!
Yeh Juvenal Ramirez #6 Go for the goal!
Yeh Xavier Perra #4 Get that ball!
Yeh Laura Dot #2 Get that ball!
Yeh Malcolm Diamond #5 Get that ball!
Yeh Mary Bart #9 Get that ball!
Yeh Linda Jarvis #3 Block that kick!
Yeh Jose Acosta #11 Guard the goal!
Yeh Tracy Lowe #10 Guard the goal!

Bees:
  Forwards:
    1: Maureen Mezzabo
    6: Juvenal Ramirez
    7: Bruce Penge
    8: Samantha Smith
  Midfielders:
    2: Laura Dot
    4: Xavier Perra
    5: Malcolm Diamond
    9: Mary Bart
  Defenders:
    3: Linda Jarvis
  Goalies:
    10: Tracy Lowe
    11: Jose Acosta
>>> 
"""
