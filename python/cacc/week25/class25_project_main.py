# Pizza slicing game version 2 - Part 2
import class25_project_function as lib

words = ["pizza", "python", "chinese"]

print(
"""
Slicing 'Cheat Sheet'
0     1     2     3     4     5
+—---+—----+—---+—---+-—---+
|  p  |  i  |  z  |  z  |  a  |
+—---+—----+—---+—---+
-5   -4    -3    -2    -1
""")

print("To play the game, please enter both begin and end indexes.")
print("Character at begin index is included, while character at end index is excluded.")

begin = lib.getIndex("Begin")

end = lib.getIndex("End")

print("")
for word in words:
    print(word[begin:end])

# 3. advanced: create a function (think about the design)
