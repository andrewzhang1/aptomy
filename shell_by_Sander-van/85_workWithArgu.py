import sys
count = len(sys.argv) - 1 
if ( count >= 1 ):
  print ("Number of arguments :" + str(count))
  for arg in sys.argv:
    print(arg)
  print("Exiting " + sys.argv[0])




