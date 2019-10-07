#!/usr/bin/env python
"""lab15.py  A Clock class"""

import time

class Clock:
    """Clock() for now, or Clock(hr, min) or Clock(min) or
    Clock("1:20") or Clock(dict) where dict has keys 'hr' and 'min'."""
    
    def __init__(self, *args, **dict_args):
        no_args = len(args)
        if dict_args:
            self.__get_dict_args(dict_args)
        elif no_args <= 1:
            if no_args == 0:
                # making args[0] Now
                args = [time.ctime()[11:16]]
            if isinstance(args[0], str):
                self.hr, self.min = args[0].split(':')
            elif isinstance(args[0], dict):
                self.__get_dict_args(args[0])
            else:  # sequence or single value
                try:
                    self.hr, self.min = args[0]
                except TypeError:
                    self.hr = 0
                    self.min = args[0]
        elif no_args == 2:
            self.hr, self.min = args
        else:
            raise TypeError, Clock.__doc__
        self.__normalize()

    def __add__(self, other):
        return Clock(self.hr + other.hr, self.min + other.min)

    def __cmp__(self, other):
        return cmp(int(self), int(other))

    def __eq__(self, other):
        if cmp(self, other) == 0:
            return True
        return False

    def __get_dict_args(self, dict_args):
        try:
            self.min = dict_args['min']
            self.hr = dict_args['hr']
        except KeyError:
            raise TypeError, Clock.__doc__

    def __int__(self):
        return self.MinutesSince12()

    def __neg__(self):
        return Clock(-self.hr, -self.min)

    def __normalize(self):
        """Assumes that self.min and self.hr are floatable and makes
        the values fit on a clock.
        """
        self.min = float(self.min) + (float(self.hr) - int(self.hr)) * 60
        self.min = int(round(self.min))
        self.hr = int(self.hr) + self.min//60
        self.min %= 60
        self.hr = 1 + (self.hr - 1) % 12

    def __repr__(self):
        return self.__class__.__name__ + """('%s')""" % str(self)

    def __str__(self):
        return "%2d:%02d" % (self.hr, self.min)

    def __sub__(self, other):
        return Clock(hr=self.hr - other.hr, min=self.min - other.min)

    def MinutesSince12(self):
        return (self.hr % 12) * 60 + self.min

def main():
    Clock()
    c1 = Clock(12, 59)
    values = 0
    for hrs in range(-2, 25, 2):
        for mins in range(-10, 10):
            c2 = Clock(hrs, mins)
            assert eval(repr(c2)) == c2
            cmp_value = int(c2)
            assert Clock(int(c2)) == c2
            c_sum = c1 + c2
            c_diff = c1 - c2
            c3 = c_sum + c_diff # should be 2 * c1
            c4 = Clock(2* c1.hr, 2 * c1.min)
            assert c3 == c4
            c5 = -c2
            assert c_diff == c1 + c5
            values += 1
    hours, minutes = 2, 30
    clocks = [Clock(hours, minutes)]
    clocks += [Clock((hours, minutes))]
    clocks += [Clock("%d:%2d" % (hours, minutes))]
    clocks += [Clock({'hr': hours, 'min': minutes})]
    clocks += [Clock(hr=hours, min=minutes)]
    for each in clocks[1:]:
        assert clocks[0] == each
    try:
        Clock(1, 2, 3)
    except TypeError:
        pass
    else:
        print "Clock(1, 2, 3) failed to raise an error"
    
if __name__ == '__main__':
    main()

"""$ lab15.py
$"""
