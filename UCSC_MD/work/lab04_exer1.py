
import random


def Coin ():
    rand = random.randrange(0, 2)
    
    if rand == 0:
        return 'H'
    else:
        return 'T'

def Experiment ():
    flips = 0
    inrow = 0
    while True:
        side = Coin();
        flips += 1
        if side == 'H':
            inrow += 1
        else:
            inrow = 0
        if inrow == 3:
            break

    return flips

MAX = 10
sum = 0
for i in range(0, MAX):
    sum += Experiment()
avg = sum/MAX

print (avg)

