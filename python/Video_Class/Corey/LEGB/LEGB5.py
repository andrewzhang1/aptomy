'''
LEGB
Local, Enclosing, Global, Built-in

script name: LEGB5.py
'''

# x = 'global x'

def test():
    global x  # We actually should try to avoid using "global variables!!"
    x = 'local x'
    #print(y)
    print (x)

test()
print (x)

# local x  (print local variable first)
# local x
