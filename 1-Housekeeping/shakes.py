# 1.12. Defining Functions — Problem Solving with Algorithms and Data Structures
# http://interactivepython.org/runestone/static/pythonds/Introduction/DefiningFunctions.html


import random

def genereatOne(strlen):
    alphabet = 'abcdefghijklmnopqrstuvwxyz '
    res = ""
    for i in range(strlen):
        res = res + alphabet[random.randrange(27)]

    return res

# print(genereatOne(5))

def score(goal, teststing):
    numSame = 0
    for i in range(len(goal)):
        numSame = numSame + 1

    return numSame / len(goal)

#print(score('methinks it is like a wisel', genereatOne(28)))

def main():

    goalstring = 'methinks it is like a wisel'
    newstring = genereatOne(28)
    best = 0
    newscore = score(goalstring, newstring)
    while newscore < 1:
        if newstring > best:
            print(newscore, newstring)
            best = newscore
        newstring = genereatOne(28)
        newscore = score(goalstring, newstring)

main()





