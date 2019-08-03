
'''
while true:


'''

result = ''

while True:
    try:
        value = int (input("Please  enter a number: "))

        result = "success"
        break
    except ValueError as ErrMsg:
        print("Ops! That was not valid number. Try again...")
        print(ErrMsg) # why we print this? we want to see why's wrong?
        result = "Result is fail"
    else:
        print("success!!")
    finally:
        print("nice try!!")

# how to break?  what about finally (which is better)?

# We can even define our own error message!