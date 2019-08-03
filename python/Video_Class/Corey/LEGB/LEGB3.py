'''
LEGB
Local, Enclosing, Global, Built-in

script name: LEGB3.py

'''

x = 'global x'

def test():
    x = 'local x'
    #print(y)
    print (x)

test()
print (x)

# local x  (print local variable first)
# global x
