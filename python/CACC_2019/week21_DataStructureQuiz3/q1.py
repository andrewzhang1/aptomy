x = 1
y = "2"
z = 3

sum = 0
for i in (x,y,z):
    if isinstance(i, int):
        sum += i
print(sum)


list1 = [2, 3,5,'t', 'r', 4 ]

sum2 = 0
for i in list1:
    if isinstance(i, int):
        sum2 += i
print(sum2)

