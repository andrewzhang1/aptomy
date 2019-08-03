
print("Try 1:\n")
try:
    f = open('testfile.txt')
    var = bad_var
# except Exception:
except FileNotFoundError:
    print('Sorry. This file does not exits')
except Exception as e:
    print(e)
    print("'sorry. Something went wrong")


print("\nTry 2:\n")
#
#
try:
    f = open('testfile.txt')
    var = bad_var2
# except Exception:
except FileNotFoundError as e:
    print('e')


#
# except Exception as e:
#     print(e)
#     print("'sorry. Something went wrong")



