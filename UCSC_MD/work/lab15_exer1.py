

from __future__ import division


class Clock:
    def __init__( self, hour, minute):
        self.hour   = hour
        self.minute = minute

    def __str__( self):
        return "%02d:%02d" % (self.hour, self.minute)

    def __add__( self, other):
        add_hour   = (self.hour + other.hour + (self.minute + other.minute)//60) % 24
        add_minute = (self.minute + other.minute) % 60
        return Clock( add_hour, add_minute)

    def __sub__( self, other):
        self_mins  = self.hour*60 + self.minute
        other_mins = other.hour*60 + other.minute
        sub_hour   = (self_mins - other_mins)//60
        sub_minute = (self_mins - other_mins) % 60
        return Clock( sub_hour, sub_minute)

    def __repr__( self):
        return "Clock( %d, %d)" % (self.hour, self.minute)


if __name__ == '__main__':
    c1 = Clock( 3, 30)
    print c1
    c2 = Clock( 1, 15)
    print c2
    print

    c3 = c1.__add__( c2)
    print c3
    c4 = c1 + c2
    print c4
    print

    c5 = c1.__sub__( c2)
    print c5
    c6 = c1 - c2
    print c6
    print
    
    c7 = eval( repr( c1))
    print c7
    c8 = eval( repr( c2))
    print c8
    print


"""
>>> 
=========== RESTART: C:/Users/E1HL/Python/exercises/lab15_exer1.py ===========
03:30
01:15

04:45
04:45

02:15
02:15

03:30
01:15

>>> 
"""
