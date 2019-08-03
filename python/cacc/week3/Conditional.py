# if statement
# Operator    Meaning                     Example Condition   Evaluates To
# ==          equal to                    5 == 5              True
# !=          not equal to                8 != 5              True
# >           greater than                3 > 10              False
# <           less than                   5 < 8               True
# >=          greater than or equal to    5 >= 10             False
# <=          less than or equal to       5 <= 5              True

length = int(input('input length: \n'))
if length > 10:
    width = 70
    area = length * width
    print('length is: ', length)

length = int(input('input length: \n'))
width = 15
if length < 10:
    width = 70
    area = length * width
    print('length is: ', length, ' width is: ', width, ' area is: ', area)
elif length < 20:
    width = 30
    area = length * width
    print('length is: ', length, ' width is: ', width, ' area is: ', area)
else:
    area = length * width

    print('length is: ', length, ' width is: ', width, ' area is: ', area)
  # area = length * width
  # print('length is: ', length, ' width is: ', width, ' area is: ', area)
