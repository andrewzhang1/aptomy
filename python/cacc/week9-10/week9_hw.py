# Design a program that:
#
# 1. firstly keep asking for input in a loop, the input should be:
# a. a string that contains a key value pair seperate by "|" sign, i.e. "key|value", e.g. "abc|several characters"
# b. if the input doesn't contain any | sign or doesn't contain key or value, provide a warning, ignore the input and keep asking for the input in a loop
# c. if the input is | itself, stop the loop
#
# 2. after leave the request loop, program will ask for the input of the key:
# a. if you have input a string with the key in step 1, return the value
# b. if you didn't input a string with the key in step 1, return "no value found"
# c. input | sign to stop the program.


def way1():
    dic = {}
    while True:
        str = input("Please type a key value pair, e.g. key|value: ")
        if '|' not in str:
            print('WARN: wrong format, correct format should be key|value !')
        elif '|' == str:
            break
        else:
            idx = str.index('|')
            dic[str[:idx]] = str[idx+1:]
    return dic


def way2():
    dic = {}
    while True:
        str = input("Please type a key value pair, e.g. key|value: ")
        arr = str.split('|')
        if len(arr) < 2:
            print('WARN: wrong format, correct format should be key|value !')
        elif '|' == str:
            break
        else:
            dic[arr[0]] = '|'.join(arr[1:])

    return dic


def find(dic):
    while True:
        str = input("Please enter a key: ")
        if str == '|': break
        print(dic.get(str, "no value found"))


dic = way2()
print(dic)
find(dic)