class User:
    pass


user1 = User()  # user1 is an instance, or an object
user1.first_name = "andrew"
user1.last_name = "zhang"

fist_name = "sheery"
last_name = "zhu"

print(user1.first_name, user1.last_name)
print(fist_name, last_name)

user2 = User()
user2.first_name = "Frank"
user2.last_name = "Poole"

user1.age = 37
user2.favarite_book = "2001: A space Odussy"

print(user1.age)
print(user2.favarite_book)

example




''' Output:

andrew zhang
sheery zhu
37
2001: A space Odussy

Process finished with exit code 0

'''
