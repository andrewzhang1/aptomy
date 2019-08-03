# Geek Translator
# Demonstrates using dictionaries


geek = {"404": "clueless.  From the web error message 404, meaning page not found.",
        "Googling": "searching the Internet for background information on a person.",
        "Keyboard Plaque" : "the collection of debris found in computer keyboards.",
        "Link Rot" : "the process by which web page links become obsolete.",
        "Percussive Maintenance" : "the act of striking an electronic device to make it work.",
        "Uninstalled" : "being fired.  Especially popular during the dot-bomb era."}

print(geek["404"])
print(geek["Link Rot"])

# find key in dic
if "Dancing Baloney" in geek:
    print("I know what Dancing Baloney is. ")
else:
    print("I have no idea what Dancing Baloney is. ")

if "Uninstalled" in geek:
    print(geek["Uninstalled"])
else:
    print("I have no idea.")

# use get
print(geek.get("Dancing Baloney"))
print(geek.get("Dancing Baloney", "I have no idea."))

# add new term to dic
geek["Data Structure"] = "In computer science, a data structure is a data organization, management and storage format that enables efficient access and modification."



