#!/usr/bin/env python
"""prof.py Demonstrates the profiler which spits out info about the
time it takes to run functions.""" 

__pychecker__ = 'no-local' 

LIMIT = 10
data = range(LIMIT)

def TryWay(i):
    try:
        return data[i]
    except:
        return None

def TestWay(i):
    if i < -len(data) or i > len(data) - 1:
        return None
    return data[i]

def TestWay2(i):
    data_len = len(data)
    if i < -data_len or i > data_len - 1:
        return None
    return data[i]

def TestThem(n):
    for i in range(n): # pychecker complains that i is unused
        TryWay(LIMIT * 2)
        TestWay(LIMIT * 2)
        TestWay2(LIMIT * 2)

if __name__ == '__main__':
    import profile
    profile.run('TestThem(10000)')
"""












$ prof.py
         60005 function calls in 0.596 CPU seconds

   Ordered by: standard name

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
    30000    0.128    0.000    0.128    0.000 :0(len)
        1    0.008    0.008    0.008    0.008 :0(range)
        1    0.000    0.000    0.000    0.000 :0(setprofile)
        1    0.000    0.000    0.596    0.596 <string>:1(<module>)
    10000    0.156    0.000    0.236    0.000 prof.py:13(TestWay)
    10000    0.124    0.000    0.172    0.000 prof.py:18(TestWay2)
        1    0.128    0.128    0.596    0.596 prof.py:24(TestThem)
    10000    0.052    0.000    0.052    0.000 prof.py:7(TryWay)
        0    0.000             0.000          profile:0(profiler)
        1    0.000    0.000    0.596    0.596 profile:0(TestThem(10000))
$     """
