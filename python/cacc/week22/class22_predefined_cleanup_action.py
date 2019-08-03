# review: try - except - else - finally (new)
def divide(x, y):
    """

    This is about the exception handling
    """

    try:
        result = x / y
    except ZeroDivisionError:
        print("division by zero!")
    else:
        print("result is", result)
    finally:
        print("executing finally clause")

divide(2, 0)
#divide(2, 0)
#divide("2", "1")

print()

help(divide(x=2, y=3))

# cleanup with open file: approach #1
'''
f = open("2019Semester2_quiz_1_file")
for line in f:
    print(line, end="")
f.close()

print()
print(f.closed)
print()
'''

# cleanup with open file: approach #2 (preferred)
'''
with open("2019Semester2_quiz_1_file") as f:
    for line in f:
        print(line, end="")
print()
print(f.closed)
'''
