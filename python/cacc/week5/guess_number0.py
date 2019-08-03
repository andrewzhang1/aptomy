import random, math

def guess():
    # do nothing, used as code block place holder,
    # should be replaced with your own logic
    print(target)
    pass

r = int(input("Type in an integer as range: "))
target = random.randint(0, r)

guess()

print('normally guess correctly within', int(math.log(r,2)),'try.')
