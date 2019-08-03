#!/usr/bin/env python  
"""printable_stack_def.py Extending our stack, providing a
"special method", __str__, which is called whenever:
   1.  "%s" % (printable_stack_object)
   2.  str(printable_stack_object)
   3.  print printable_stack_object
"""
    
import lab14_2 as stack_def  # copy of lab exercise
    
class PrintableStack(stack_def.Stack):
    """This class will reveal itself, and the result looks
    like a stack."""
    def __str__(self):
        try:
            min_width = max([len(thing) for thing in self.things])
        except ValueError: # self.things was empty
            min_width = 4
            center = ' [] '
        else:
            center = '|\n|'.join([thing.center(min_width) \
                                  for thing in self.things])
        top = ' '+ '-' * min_width + '\n|'
        bottom = '|\n ' + '-' * min_width + '\n'
        return top + center + bottom
    
def main():
    box = stack_def.Stack()
    print box
    for food in ['bread','mayo','cheese']:
        print 'Stack pushing', food
        box.push(food)
    print box
    print 'PrintableStack shows its stack'
    pbox = PrintableStack()
    print pbox
    for food in ['bread','mayo','cheese']:
        print 'PrintableStack pushing', food
        pbox.push(food)
        print pbox
    for i in range(3):
        print 'PrintableStack popping', pbox.pop()
        print pbox
if __name__ == '__main__':
    main()
"""
$ python -i stack.py
<__main__.Stack instance at 0x814dfd4>
Stack pushing bread
Stack pushing mayo
Stack pushing cheese
<__main__.Stack instance at 0x814dfd4>
PrintableStack shows its stack
 ----
| [] |
 ----
PrintableStack pushing bread
 -----
|bread|
 -----
PrintableStack pushing mayo
 -----
| mayo|
|bread|
 -----
PrintableStack pushing cheese
 ------
|cheese|
| mayo |
|bread |
 ------
PrintableStack popping cheese
 -----
| mayo|
|bread|
 -----
PrintableStack popping mayo
 -----
|bread|
 -----
PrintableStack popping bread
 ----
| [] |
 ----
>>> dir(box)
['__doc__', '__init__', '__module__', 'pop', 'push', 'things']
>>> print box.things
['bread', 'mayo', 'cheese']     """
