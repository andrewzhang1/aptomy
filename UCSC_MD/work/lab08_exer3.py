

for r in range(6):
    for n in [r*c for c in range(5)]:
        print "%4d" % (n),                  # columns 0 .. 4, followed by space
    print "%4d" % (r*5)                     # column  5,      followed by \n

print                                       # \n between nested loops and one liner

# construct a one line print statement
#                                   r*c
#                          '%4d' % (r*c)
#                         ['%4d' % (r*c) for c in range(6)]
#                ' '.join(['%4d' % (r*c) for c in range(6)])
#               [' '.join(['%4d' % (r*c) for c in range(6)]) for r in range(6)]
#     '\n'.join([' '.join(['%4d' % (r*c) for c in range(6)]) for r in range(6)])
print '\n'.join([' '.join(['%4d' % (r*c) for c in range(6)]) for r in range(6)])


"""
>>> 
=========== RESTART: C:\Users\E1HL\Python\exercises\lab08_exer3.py ===========
   0    0    0    0    0    0
   0    1    2    3    4    5
   0    2    4    6    8   10
   0    3    6    9   12   15
   0    4    8   12   16   20
   0    5   10   15   20   25

   0    0    0    0    0    0
   0    1    2    3    4    5
   0    2    4    6    8   10
   0    3    6    9   12   15
   0    4    8   12   16   20
   0    5   10   15   20   25
>>> 
"""
