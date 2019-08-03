
if True:
    print("True")

#1 / 0

#4 + spam*3  # variable was not defined
spam = 2
4 + spam*3

# '2' + 3

'''
while true:


'''

result = ''

while True:
    try:
        value = int (input("Please  enter a number: "))
        break
    except ValueError as ErrMsg:
        print("Ops! That was not valid number. Try again...")
        print(ErrMsg) # why we print this? we want to see why's wrong?
    else:
        print("success!!")
    finally:
        print("nice try!!")

# how to break?  what about finally (which is better)?

