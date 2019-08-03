# Dealing with file read and write
# file = open(filename, mode)
# read all of the file
file = open('introduction.txt') # open('introduction.txt', 'r')
s = file.read()
print(s)
file.close()

# read list of lines
file = open('introduction.txt') # open('introduction.txt', 'r')
l = file.readlines()
print(l)
file.close()

# read line by line
with open('introduction.txt') as file:
    for l in file:
        print(l)

# write to file line by line
with open('file1.txt', 'wt') as file:
    file.write('beginning')
    file.write(' still same line\n')
    file.write('new line.')

poem = '''There was a young lady named Bright,
Whose speed was far faster than light;
She started one day
In a relative way,

And returned on the previous night.'''

with open('file1.txt', 'wt') as file:
    file.write(poem)

with open('file1.txt', 'a') as file:
    print(poem, file=file)
# write to file from list

lines_of_text = ["One line of text here", "and another line here", "and yet another here", "and so on and so forth"]

with open('file2.txt', 'wt') as file:
    file.writelines(lines_of_text)

