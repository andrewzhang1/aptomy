import datetime

class User:
    """A memeber of FriendFace. For now we are
    only storing their name and birthday.
    But soon we will store an uncomfortable
    amount of user information.

    """

    def __init__(self, full_name, birthday):
        #pass
        self.name = full_name
        self.birthday = birthday
        # Extract first name and last name
        name_pieces = full_name.split(" ")
        self.first_name = name_pieces[0]
        self.last_name = name_pieces[-1]


    def age(self):
        """Return the age of the user in years"""
        today = datetime.date(2019, 7, 2)
        yyyy = int(self.birthday[0:4])
        mm = int(self.birthday[4:6])
        dd = int(self.birthday[6:8])
        dob = datetime.date(yyyy, mm, dd) # Date of birth
        age_in_years = (today - dob).days
        age_in_years = age_in_years /365
        return int(age_in_years)




print("Your Full Name: ", user.name, user.birthday)
print(user.first_name)
print(user.last_name)
print(user.birthday)


user = User("Andrew Zhang", "19620928")

print("My age is :", user.age())


help(user)



'''Output:


'''