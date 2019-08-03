'''
LEGB

 Enclosing: a function in a function


script Name: LEGB8-3.py

'''


#x = 'global x'

def outer():
    #x = 'outer x'

    def inner():
        x = 'inner x'
        print (x)

    inner()
    print (x)

outer()

'''
will have error! 

'''




#print(x)
