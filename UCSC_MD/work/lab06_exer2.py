

list = []
for i in range(5):
    while True:
        rnum = raw_input('Input a number: ')
        if rnum:
            try:
                num = int(rnum)
                break
            except ValueError:
                print 'Input must be a number'
        else:
            print 'Input must not be null'

    if num not in list:
        print 'New number: %d' %(num)
        list += [num]

print list
