import time

S=[x for x in range(1000000)]
T=[y**2 for y in range(300)]
#
#
time1 = time.time()
N=[x for x in S for y in T if x==y]
time2 = time.time()
print ('time diff [x for x in S for y in T if x==y]=', time2-time1)
#print N
#
#
time1 = time.time()
N=filter(lambda x:x in S,T)
time2 = time.time()
print 'time diff filter(lambda x:x in S,T)=', time2-time1
#print N
#
#
#http://snipt.net/voyeg3r/python-intersect-lists/
time1 = time.time()
N = [val for val in S if val in T]
time2 = time.time()
print 'time diff [val for val in S if val in T]=', time2-time1
#print N
#
#
time1 = time.time()
N= list(set(S) & set(T))
time2 = time.time()
print 'time diff list(set(S) & set(T))=', time2-time1
#print N  #the results will be unordered as compared to the other ways!!!
#
#
time1 = time.time()
N=[]
for x in S:
    for y in T:
        if x==y:
            N.append(x)
time2 = time.time()
print 'time diff using traditional for loop', time2-time1
#print N