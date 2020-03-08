# Script2.py

def sum_items(list1, list2):
    '''(list of number, list of number

    Return a new list in which each item is the sum of
    the items at the corresponding position of list1 and list2.

    Precondition: len(list1) = len(list2)

    '''

    sum_list = []

    for i in range(len(list1)):
        sum_list.append(list1[i] + list2[i])

    return sum_list

sum = sum_items([1,2,3], [2,4,2])
print(sum)