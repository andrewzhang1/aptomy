#!/usr/bin/env python
"""  
Optional, except for the 'has a' relationship.

Here we implement the diagram, demonstrating a 'contains a' 
or 'has a' relationship between classes, and a pseudo-private
attribute and method.  Inheritance is a 'is a' relationship.

Below, in PersonnelDept.__init__, notice that there is
self.__welcomers.  This is a "private" attribute because it has 2
leading underscores and no more than 1 trailing underscore.  It gets
mangled to _PersonnelDept__welcomers (_ClassName + attribute_name) so
that, from outside the class, __welcomers does not exist.
"""
import welcomer_def   
        
class Store:
    def __init__(self, name):
        self.name = name
        self.hr = PersonnelDept(self.name) # Store *has a*
                                           # PersonnelDept
class PersonnelDept:
    def __init__(self, name):
        self.__welcomers = [] 
        self.store_name = name
        
    def Hire(self, name):
        new_guy = welcomer_def.Welcomer(name)
        self.__welcomers += [new_guy]
        print self.store_name, "welcomes %s, our new welcomer." % new_guy
        return new_guy

    def __find(self, name):
        for (i, worker) in enumerate(self.__welcomers):
            if worker.name == name:
                return i
        return -1

    def Fire(self, name):
        index = self.__find(name)
        if index == -1:
            return name, "doesn't work here."
        x = self.__welcomers.pop(index)
        print "%s, you are terminated.  Thank you and good luck." % x





def main():
    flormart = Store('FlorMart')
    jane = flormart.hr.Hire('Jane')
    jane.SetSalary(20000)
    jane.Greet()
    print jane, "here's $%.2f for you. " % jane.CalculatePay(2)
    print """Calling Jane("You're in trouble")"""
    print jane, 'replies:'
    jane("You're in trouble")
    flormart.hr.Fire('Jane')

if __name__ == '__main__':
    main()
"""
$ python -i store_def.py
FlorMart welcomes Jane, our new welcomer.
Hello World
I'm Jane
Jane here's $769.23 for you. 
Calling Jane("You're in trouble")
Jane replies:
You're in trouble yourself!
Jane, you are terminated.  Thank you and good luck.
Jane says "Oh no!"
>>> store = Store("A Store")
>>> print store.hr.__welcomers
Traceback (most recent call last):
  File "<stdin>", line 1, in ?
AttributeError: PersonnelDept instance has no attribute '__welcomers'
>>> print store.hr._PersonnelDept__welcomers
[]
>>> 
$ 
"""
