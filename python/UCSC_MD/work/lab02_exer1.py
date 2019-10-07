

while True:
    raw1 = raw_input('Input first  integer: ')
    if raw1:
        try:
            int1 = int(raw1)
            break
        except ValueError:
            print 'Input must be integer'
    else:
        print 'Input must not be null'

while True:
    raw2 = raw_input('Input second integer: ')
    if raw2:
        try:
            int2 = int(raw2)
            break
        except ValueError:
            print 'Input must be integer'
    else:
        print 'Input must not be null'

if int1 % int2 == 0:
    print '%d is a multiple of %d' %(int1, int2)
else:
    print '%d is not a multiple of %d' %(int1, int2)
