

while True:
    name = raw_input('Name: ')
    if name:
        break
    else:
        print 'Name must not be null'

while True:
    rscore = raw_input('Score: ')
    if rscore:
        try:
            score = int(rscore)
            if 0 <= score and score <= 100:
                break
            else:
                print 'Score must be between 0 and 100'
        except ValueError:
            print 'Score must be an integer'
    else:
        print 'Score must not be null'

if   90 <= score:
    grade = 'A'
elif 80 <= score:       # and score <= 89:
    grade = 'B'
elif 70 <= score:       # and score <= 79:
    grade = 'C'
elif 60 <= score:       # and score <= 69:
    grade = 'D'
else:
    grade = 'F'

print 'Name = %s, Grade = %s' %(name, grade)


"""
>>> 
=========== RESTART: C:\Users\E1HL\Python\exercises\quiz1_exer1.py ===========
Name: Jean
Score: 95
Name = Jean, Grade = A
>>> 
"""
