#!/usr/bin/env python
"""
Demonstrates the setattr and getattr functions for dynamic
code generation, which is preferred to exec and eval.

The first argument to setattr and getattr is the namespace
where you expect the variable to land.  sys.modules is
helpful here if you want it in the current namespace.
""" 
import sys 

VARIABLES = ("name", "zip", "phone", "SSN")

def GetVariables(variables):
    for each in variables:
        answer = raw_input("%s please: " % each)
        setattr(sys.modules[__name__], each, answer)

def PrintVariables(variables):
    for each in variables:
        print each, '=', getattr(sys.modules[__name__], each)
    
def main():
    if len(sys.argv) > 1:
        variables = sys.argv[1:]
    else:
        variables = VARIABLES
    GetVariables(variables)
    PrintVariables(variables)

if __name__ == '__main__':
    main()

"""
Same output.
"""
