import sys
count = len(sys.argv)
name = ''
if ( count == 1 ):
  name = input("Give a name: ")
else: 
  name = sys.argv[1]

print ("Hello " + name)
print("Exiting " + sys.argv[0])




