

names    = ["Jack Sparrow", "George Washington", "Tiny Sparrow", "Jean Ann Kennedy"]
revnames = []

for name in names:
    #revname   = ' '.join([name.split()[-1] + ','] + name.split()[:-1])
    parts     = name.split()
    revname   = parts[-1] + ', ' + ' '.join(parts[:-1])

    revnames += [revname]

revnames.sort()

for revname in revnames:
    print revname


"""
>>> 
=========== RESTART: C:\Users\E1HL\Python\exercises\lab06_exer3.py ===========
Kennedy, Jean Ann
Sparrow, Jack
Sparrow, Tiny
Washington, George
>>> 
"""
