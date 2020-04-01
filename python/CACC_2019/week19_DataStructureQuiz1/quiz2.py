# Better to use "Trus" and "False"
def is_prime(x):
    # up to sqrt(n)
    if x == 1:
        return False
    for i in range(2, x):
        if x % i == 0:
            return False
    return True

# Run a test
for i in range(1, 20):
    print (i, is_prime(i))
