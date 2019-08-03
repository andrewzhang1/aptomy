################
# loop statement

# while loop
response = ""
while response.lower() != "yes":
    response = input("Want to learn python?\n")

print("Oh. Okay.")

count = 0
while True:
    count += 1

    # end loop if count greater than 10
    if count > 10:
        break
    # skip 5
    if count == 5:
        continue
    print(count)

# for loop

word = input("Enter a word: ")

print("\nHere's each letter in your word:")
for letter in word:
    print(letter)
