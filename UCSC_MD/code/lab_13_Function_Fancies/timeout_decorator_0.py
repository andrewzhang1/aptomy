#! /usr/bin/env python
'''(Optional and esoteric, but useful).Decorator to time out
after one second.  Simplified from the example by Chris Wright
from the online the ASPN Cookbook.  I found it by Googling.'''

import signal, time 
                    
TIME_OUT = 1
def TimeOut(Func):

    def FunctionWrapper(*args, **kwargs):
        def AlarmHandler(signum, frame):
            all_args = ', '.join([str(a) for a in args] \
                                 + ["%s=%s" % (k,v) \
                                    for (k, v) in kwargs.items()])
            print "%s(%s) timed out at %d seconds." \
                  % (Func.__name__, all_args, TIME_OUT)
            raise RuntimeError

        old = signal.signal(signal.SIGALRM, AlarmHandler)
        signal.alarm(TIME_OUT)
        try:
            result = Func(*args, **kwargs)
        finally:
            signal.signal(signal.SIGALRM, old)
            signal.alarm(0)
        return result        
    return FunctionWrapper

@TimeOut
def main():
    try:
        time.sleep(2)
    except RuntimeError:
        pass

if __name__ == '__main__':
    main()
    
"""
$ timeout_decorator_0.py
main() timed out at 1 seconds.
"""
