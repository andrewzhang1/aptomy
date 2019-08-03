import re
'''
this is for regular expression
'''

str = 'an example word:cat!!'
match = re.search(r'cat', str)
print(match.group())

myList = [3, 5,7,9, 100, 'Python', 'Java','c']
print(myList[6])

total =1
for x in range(1, 8):
    total *= x

print(total)

help()