import random

def guess(lower, upper, t=1):
    g = (lower + upper) // 2
    if g == target:
        print("Got it correct in", t, "try")
    elif g < target:
        print("Guess number", g, 'is too small,', t, 'try')
        guess(g+1, upper, t+1)
    else:
        print("Guess number", g, 'is too large,', t, 'try')
        guess(lower, g-1, t+1)

r = int(input("Type in an integer as range: "))
target = random.randint(0, r)

print('target', target)
guess(0,r)
