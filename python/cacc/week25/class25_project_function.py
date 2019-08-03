def getIndex(name):
    index = None
    while index != "":
        index = (input("\n" + name + ": "))
        if index:
            try:
                index = int(index)
            except ValueError as ve:
                print("Oops! That was not valid number. Try again...")
                index = None
            else:
                break
    return index

