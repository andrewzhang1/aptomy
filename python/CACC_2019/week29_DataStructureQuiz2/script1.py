
# Script1.py

grates = [80, 90, 70]

print(grates[1])
print(grates[1:2])


print(len(grates))

print(sum(grates))
subjects = ['bio', 'cs', 'math', 'history', 3]

print(len(subjects))

#sum(subjects)

# How to print
for item in grates:
    print(item)


for item in subjects:
    print(item)

squares = [x ** 2 for x in [2, 3, 4, 6]]
print(squares)

# Comprehension way
squares = [x ** 2 for x in [ 2, 3, 4, 6]]
print(squares)