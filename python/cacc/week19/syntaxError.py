
if True:
    print("True")

#1 / 0  # this is a good sample to write an user defined error message

#4 + spam*3  # variable was not defined
spam = 2
4 + spam*3

# '2' + 3

'''
while true:


'''
# Home work 1 / 0 using try and except

while True:
    try:
        value = int (input("Please  enter a number: "))
        1 / value

        #break
    except ValueError as ErrMsg:
        print("Ops! That was not valid number. Try again...")
        print(ErrMsg) # why we print this? we want to see why's wrong?
    else:
        print("success!!")
    break

# how to break?  what about finally (which is better)?

