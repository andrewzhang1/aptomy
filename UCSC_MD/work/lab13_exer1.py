

"""
"""


def Printf( format, *items):
    """
    Input:   items is caller's sequence of args, as a tuple
    Returns: None, just print to stdout
    """

    print format % items


if __name__ == '__main__':
    Printf( "%s is %s %d",  'this', 'test',  1)
    Printf( "%s worked %s", 'this', 'ok')
    Printf( "%s is %s %d",  'that', 'trial', 2)
    Printf( "%s is %s",     'that', 'fine')


"""
>>> 
============= RESTART: C:/Users/E1HL/Python/exercises/lab13_1.py =============
this is test 1
this worked ok
that is trial 2
that is fine
>>> 
"""
