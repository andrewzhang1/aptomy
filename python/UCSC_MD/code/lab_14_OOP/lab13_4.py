#!/usr/bin/env python
"""lab13_4.py A logging lotto facility."""
import time
import random

LOG_FILE = 'lotto.log'

def LogIt(func):
    """Decorator function for logging output from the func."""
    def LoggedFunction(*t_args, **kw_args):
        f = open(LOG_FILE, "a")
        got = func(*t_args, **kw_args)
        f.write("%s  ->%s\n" % (time.ctime(), got))
        f.close()
        return got
    return LoggedFunction

@LogIt
def Lotto():
    return random.sample(xrange(1, 53), 6)

def PrintLotto(the_pick):
    print ", ".join([str(x) for x in the_pick])

def main():
    PrintLotto(Lotto())
    PrintLotto(Lotto())

if __name__ == '__main__':
    main()
    
"""$ lab13_4.py
35, 10, 12, 47, 24, 48
34, 12, 22, 27, 38, 46
$ cat lotto.log
Mon Mar  1 11:41:42 2010  ->[42, 27, 38, 35, 17, 3]
Mon Mar  1 11:41:42 2010  ->[13, 27, 51, 49, 32, 30]
Mon Mar  1 11:41:52 2010  ->[35, 10, 12, 47, 24, 48]
Mon Mar  1 11:41:52 2010  ->[34, 12, 22, 27, 38, 46]
$"""
