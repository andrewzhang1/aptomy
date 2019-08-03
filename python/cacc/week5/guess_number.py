import random

r = int(input("Type in an integer as range: "))

target = random.randint(0, r)

while True:
    g = int(input("Input your guess: "))
    if g == target:
        print('you got it correct')
        break
    elif g < target:
        print('too small')
    else:
        print('too large')
