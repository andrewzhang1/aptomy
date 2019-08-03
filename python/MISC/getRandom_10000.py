# A utility to sample 10000 randomly from 700,000,000 rows

import random

# max_index = 700,000,000
# num_sample= 10,000
max_index = 11
num_sample= 5


indices = set()

for i in range(num_sample):
    x = random.randint(0, max_index)
    while x in indices:
        x = random.randint(0, max_index)
    indices.add(x)
#    print x

rows = []
#with open("/home/andrew/QA_HOME/test_100milion/xaa700m_row.csv", "rb") as f:
with open("/Users/axz1191/Documents/azhang/aptomy/MachineLearningA-Z/Part 1 - Data Preprocessing/Data.csv", "rb") as f:

    for i in range(max_index):
        line = f.readline()
        if i in indices:
            rows.append(line)

#print rows

# Write an output file:
file = open("sample_10000row.txt", "wb")

for item in rows:
    file.write(item)

file.close()

print("Done, please see file at:")

'''
1) 
France,44,72000,No
Spain,27,48000,Yes
Germany,40,,Yes
Spain,,52000,No

2) 
France,44,72000,No
Germany,30,54000,No
Germany,40,,Yes
France,48,79000,Yes
Germany,50,83000,No

3)
Country,Age,Salary,Purchased
Germany,30,54000,No
France,35,58000,Yes
Germany,50,83000,No
France,37,67000,Yes


'''
