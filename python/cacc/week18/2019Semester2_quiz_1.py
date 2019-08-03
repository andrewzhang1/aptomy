#1 You have the following numbers and Strings: 3, 5, 5, 7, 9, 100,
# 'Python', 'Java', 'C', define a set,
# list (stack and/or queue), tuple, dictionary

# this is an example as part of answer to question #1
mySet = {3, 5, 5, 7, 9, 100, 'Python', 'Java', 'C'}
print('Set: ', mySet)

myTuple = (3, 5, 5, 7, 9, 100, 'Python', 'Java', 'C')
print("myTuple: ", myTuple)

mylist = [3, 5, 5, 7, 9, 100, 'Python', 'Java', 'C']
print("mylist: ", mylist)

dictionary = {3, 5, 5, 7, 9, 100, 'Python', 'Java', 'C'}
print("dictionary: ", mylist)


#2 Write a function to calculate fib(n). 'n' is the count, e.g. fib(2)
# should print out: 0,1,1,2,3,5,8,13

def fibonacci(n):
    if n ==1:
        return 1
    elif n ==2:
        return 1
    elif n > 2:
        return fibonacci(n-1) + fibonacci(n-2)

for n in range(0,9):
        print(n, ",", fibonacci(n))



#3 You have a text file with two lines. The first line is "Python 102",
# and the second line "I'm learning a lot".
# Write a function to read the file, and print out completely.
# Bonus: create the file using Python code as well, and not through text editor.

# Answer key3:
#=============
# Remove the file if existed on pwd if we need to run multiple time
import os
if os.path.exists("Part-3.txt"):
    os.remove("Part-3.txt")

# Defile a function and decide the file name to be written: Part3.txt
x = ["Python 102", "I'm learning a lot"]
with open('Part-3.txt', 'a') as the_file:
    the_file.write(x[0] +'\n')
    the_file.write(x[1] +'\n')

    the_file.close

# 3. Check the result
print ("\nAnswer Key 3: Write and Check the content for the file")
with open('Part-3.txt', 'r') as foo:
    for items in foo.readlines():
        print (items.strip())
