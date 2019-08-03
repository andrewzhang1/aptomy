#1 You have the following numbers and Strings: 3, 5, 5, 7, 9, 100, 'Python', 'Java', 'C', define a set, list (stack and/or queue), tuple, dictionary

mySet = {3, 5, 5, 7, 9, 100, 'Python', 'Java', 'C'}
print('Set: ', mySet)

myListStack = [3, 5, 5, 7, 9, 100, 'Python', 'Java', 'C']
myListStack.pop()
print('List as Stack: ', myListStack)

from collections import deque
myListQueue = deque([3, 5, 5, 7, 9, 100, 'Python', 'Java', 'C'])
myListQueue.popleft()
print('List as Queue', myListQueue)

myTuple = 3, 5, 5, 7, 9, 100, 'Python', 'Java'
myTuple = myTuple, 'C'
print('Tuple: ', myTuple)

myDict={1:3, 2:5, 3:5, 4:7, 5:9, 6:100, '7':'Python', '8':'Java', '9':'C'}
print( myDict )
for k, v in myDict.items():
    print(k, ' ==-> ', v)

#2 Write a function to calculate fib(n). 'n' is the count, e.g. fib(2) should print out: 0,1
def fib_2(count):           # count: easier with "for"
    a, b = 0, 1
    for i in range(count):
        if i < count-1:
            print(a, end=',') # "end" keyword avoids new line
        else:
            print(a)
        a, b = b, a+b

fib_2(10)

#3 Create a text file with two lines. The first line is "Python 102", and the second line "I'm learning a lot".
# Write a function to read the file, and print out completely.
file = open('2019Semester2_quiz_1_file')
s = file.read()
print(s)
file.close()