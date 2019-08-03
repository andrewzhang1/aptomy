'''
LEGB

 Enclosing: a function in a function


script Name: LEGB9-2.py

'''

x = 'global x'

def outer():
    #x = 'outer x'

    def inner():
        #x = 'inner x'
        print (x)

    inner()
    print (x)

outer()
print (x)


'''
global x
global x
global x
'''

