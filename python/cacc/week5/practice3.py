import random

# random.randint(a, b)
# Return a random integer N such that a <= N <= b. Alias for randrange(a, b+1).

ch, ct = 0, 0
for i in range(100):
    if random.randint(0,1) == 0:
        ch += 1
    else:
        ct += 1
print(ch, ct)
