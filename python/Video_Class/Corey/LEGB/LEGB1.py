'''
(3) Python Tutorial: Variable Scope - Understanding the LEGB rule and global/nonlocal statements - YouTube
https://www.youtube.com/watch?v=QVdf0LgmICw

LEGB
Local, Enclosing, Global, Built-in

script name: LEGB1.py
'''


x = 'global x'

def test():
    y = 'local y'
    print(y)

test()

# local y
