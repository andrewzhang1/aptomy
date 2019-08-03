'''
LEGB:
(3) Python Tutorial: Variable Scope - Understanding the LEGB rule and global/nonlocal statements - YouTube
https://www.youtube.com/watch?v=QVdf0LgmICw


Local, Enclosing, Global, Built-in

script name: LEGB2.py

'''

x = 'global x'

def test():
    y = 'local y'
    #print(y)
    print (x)

test()
print (x)

# global x
# global x
