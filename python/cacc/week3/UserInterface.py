print("Welcome to User Interface.")

username = ""
while not username:
    username=input("Enter Username: ")

password=""
retry = 0
while True:
    password = input("Enter your password: ")
    if password == "secret":
        print("Access Granted")
        break
    elif retry < 2:
        print("Wrong password, enter again: ")
        retry += 1
    else:
        print("Access Denied")
        exit()



import random

mood = random.randint(1, 3)

print("weather today is: ")

if mood == 1:
    print("""

       sunny

    """)
elif mood == 2:
    # neutral
    print( \
    """

        cloudy

    """)
elif mood == 3:
    print( \
    """
        rainy

    """)
else:
    print("Illegal mood value! (You must be in a really bad mood).")
