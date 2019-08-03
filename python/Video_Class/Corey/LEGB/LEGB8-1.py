'''
LEGB

 Enclosing: a function in a function


script Name: LEGB8-1.py

'''


#x = 'global x'

def outer():
    x = 'outer x'

    def inner():
        x = 'inner x'
        print (x)

    inner()
    print (x)

outer()

'''
inner x
outer x
'''




#print(x)
