

data = 'abc'
print "string: ",
for datum in data:
    print datum


data = ('a','b','c')
print "tuple: ", 
for datum in data:
    print datum

data = ['a','b','c']
print "list: ", 
for datum in data:
    print datum

data = {1:'a', 2:'b', 3:'c'}
print "dict: ",
for datum in data:
    print datum

data3 = {0:'a', 1:'b', 2:'c'}
print "dict3: ",
print data3.keys()
#for index in data3.keys():
for index in range(len(data3)):
    print index, data3[index]
#print data3[data3.keys()[0]]

data2 = {0:'a', 1:'b', 2:'c'}
print "dict2: ",
for index in range(len(data2)):
    print data['index']

"""
class MyException:
    def __init__(self, *args):
        Exception.__init__(self, *args)
"""

class MyException:
    pass
