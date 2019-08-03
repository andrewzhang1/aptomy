'''
LEGB

 Enclosing: a function in a function


script Name: LEGB8-4.py

'''


#x = 'global x'

def outer():
    x = 'outer x'

    def inner():
        nonlocal x
        x = 'inner x'
        print (x)

    inner()
    print (x)

outer()

'''
inner x
inner x

'''




#print(x)
