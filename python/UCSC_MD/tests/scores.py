

while True:
    score_string = input("Score please: ")
    if not score_string:
        break
    try:
        score = int(score_string)
    except ValueError:
        print ("That's not a valid score.")
    else:
        if score >= 90:
            grade = 'A'
        elif score >= 80:
            grade = 'B'
        elif score >= 70:
            grade = 'C'
        elif score >= 60:
            grade = 'D'
        else:
            grade = 'F'
        print ("Your grade is %s." % (grade))
        break
