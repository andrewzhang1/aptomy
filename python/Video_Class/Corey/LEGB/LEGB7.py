'''
LEGB

 Built-in

script Name: LEGB7.py
'''

import builtins

#print (dir(builtins))

def my_min():
    '''
    It will get an error if just use min() function; because when run this min function here, python found out min
    function in the global scope before it fell back to the built-in scope! So change min() to my_min, then it works
    fine
    '''
    pass

m = min([5, -1,4,2,3])
print(m)


#print(m)

#x = 'global x'
def test(z):
    #global x
    x = 'local x'
    #print(y)
    print(x)

# -1
