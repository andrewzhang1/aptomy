#!/usr/bin/env python
"""Scope issue with lists """ 

tea = ['earl grey', 'camomile', 'chai']

def AppendTea():
    tea.append('green') # <-- Good because we don't assign (bind)
                        #     the name, we use the function of
                        #     an existing name.
def AssignTea(): 
    global tea
    tea += ['blackberry']  # <- But for assignment, we need global
                           #    because it will try to bind the name
                           #    to the local namespace and fail.
def PlusAddTea():
    tea += ['peppermint']  #  <- No good

def main():
    AppendTea()
    print tea
    AssignTea()
    print tea
    PlusAddTea()

if __name__ == '__main__':
    main()
"""
$ list_scopes.py
['earl grey', 'camomile', 'chai', 'green']
['earl grey', 'camomile', 'chai', 'green', 'blackberry']
Traceback (most recent call last):
  File "./list_scopes.py", line 26, in <module>
    main()
  File "./list_scopes.py", line 23, in main
    PlusAddTea()
  File "./list_scopes.py", line 16, in PlusAddTea
    tea += ['peppermint']  #  <- No good
UnboundLocalError: local variable 'tea' referenced before assignment
$
"""
