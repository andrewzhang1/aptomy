'''
LEGB
Local, Enclosing, Global, Built-in

script name: LEGB4.py
'''

x = 'global x'

def test():
    global x
    x = 'local x'
    #print(y)
    print (x)

test()
print (x)

# local x  (print local variable first)
# local x
