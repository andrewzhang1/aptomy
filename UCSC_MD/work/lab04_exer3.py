

from __future__ import division
import random


def Flashcard ():
    MAX = 12
    num1 = random.randrange(0, MAX+1)
    num2 = random.randrange(0, MAX+1)
    prod = raw_input ('What is %d * %d: ' %(num1, num2))
    
    if int(prod) == num1 * num2:
        print  'Right!',                # comma for <space> instead of <newline>
        Praise()
        return 1
    else:
        print  'Almost, the right answer is %d' %(num1*num2)
        return 0


def Quiz (n):
    correct = 0
    for i in range(n):
        correct += Flashcard()
    score = (correct/n)*100
    
    print  'Score is %d' %(score)
    return score


def Feedback (p):
    if p == 100:
        print 'Perfect!'
    elif p >= 90:
        print 'Excellent'
    elif p >= 80:
        print 'Very good'
    elif p >= 70:
        print 'Good enough'
    else:
        print 'You need more practice'


def Praise ():
    num = random.randrange(0, 5)
    if num == 0:
        print 'Right On!'
    elif num == 1:
        print 'Good Work!'
    elif num == 2:
        print 'Cool!'
    elif num == 3:
        print 'Swell!'
    else:
        print 'Superb!'


Feedback(Quiz(10))
