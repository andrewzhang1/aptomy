#!/usr/bin/env python
"""Demonstrates the exec statement and eval function, used
for dynamic code generation.
""" 
import sys 

VARIABLES = ("name", "zip", "phone", "SSN")

def GetVariables(variables):
    for each in variables:
        answer = raw_input("%s please: " % each)
        exec "%s = '%s'" % (each, answer) in globals()

def PrintVariables(variables):
    for each in variables:
        print each, '=', eval(each)
    
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
$ dynamic.py name money_in_pocket
name please: Linda
money_in_pocket please: $1.25
name = Linda
money_in_pocket = $1.25
$ dynamic.py
name please: Marilyn
zip please: 94043
phone please: 650 814-4435
SSN please: XXX-XX-XXXX
name = Marilyn
zip = 94043
phone = 650 814-4435
SSN = XXX-XX-XXXX
$"""
