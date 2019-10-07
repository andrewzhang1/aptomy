

while True:
    raw = raw_input ('Input an integer: ')
    if raw:
        try:
            int = int(raw)
            break
        except ValueError:
            print 'Input must be an integer'
    else:
        print 'Input must not be null'

print '%d in decimal is in octal: %#o' %(int, int)
print '%d in decimal is in hex:   %#x' %(int, int)
