

print "%4x" %(8*16 + 10)
print "%4x" %(137.8)                # truncate                
print "%4x" %(138.9)                # truncate

print "%10.3f" %(232.346)
print "%10.3f" %(232.34)            # short number string
print "%10.3f" %(232.3459)          # round up
print "%10.3f" %(232.3461)          # round down

print "%-12.2e|" %(233)
print "%-12.2e|" %(232.9)           # round up
print "%-12.2e|" %(233.1)           # round down           

print "%-30s|"    %('string')
print "%-30s|"    %('stringstringstringstringstringstring')     # long string not truncated
print "%-30.30s|" %('stringstringstringstringstringstring')     # long string     truncated

print "%8.8s|"  %('stringstring')
print "%8.8s|"  %('string')         # short string
print "%-8.8s|" %('string')         # short string left justified

print "%+.2f" %(3.13)
print "%+.2f" %(3.1)                # short number string                
print "%+.2f" %(3.129)              # round up
print "%+.2f" %(3.131)              # round down


"""
>>> 
=========== RESTART: C:\Users\E1HL\Python\exercises\quiz1_exer2.py ===========
  8a
  89
  8a
   232.346
   232.340
   232.346
   232.346
2.33e+02    |
2.33e+02    |
2.33e+02    |
string                        |
stringstringstringstringstringstring|
stringstringstringstringstring|
stringst|
  string|
string  |
+3.13
+3.10
+3.13
+3.13
>>> 
"""
