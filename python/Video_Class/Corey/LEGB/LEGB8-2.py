'''
LEGB

 Enclosing: a function in a function


script Name: LEGB8-2.py

'''


#x = 'global x'

def outer():
    x = 'outer x'

    def inner():
        #x = 'inner x'
        print (x)

    inner()
    print (x)

outer()

'''
outer x   ==> enclosing scope
outer x
'''




#print(x)
