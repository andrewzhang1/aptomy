# Script2.py

def count_matches(s1, s2):
    '''(str, str) -> int

    Return the number of positions in s1 that
    contain the same character at the corresponding
    position of s2.

    Precondition: len(s1) = len(s2)

    '''

    num_mataches = 0

    for i in range(len(s1)):
        if s1[i] == s2[i]:
            num_mataches = num_mataches + 1

    return num_mataches

con = count_matches('abcdoefd', 'afcgdfd')
print(con)