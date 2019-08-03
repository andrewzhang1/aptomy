# Pizza Slicer - Demonstrates string slicing
# Can you make it better?

word = "pizza"
print (
    """
    Slicing 'Cheat Sheet'
    0     1     2     3     4     5
    +—---+—----+—---+—---+-—---+
    |  p  |  i  |  z  |  z  |  a  |
    +—---+—----+—---+—---+
    -5   -4    -3    -2    -1
    """
)
print ("Enter the beginning and ending index for your slice of 'pizza'.")
print ("Press the enter key at 'Begin' to exit.")
begin = None
while begin != "":
    begin = (input("\nBegin: "))
    if begin:
        begin = int(begin)
        end = int(input("End: "))
        print ("word[", begin, ":", end, "]\t\t", word[begin:end])
    input("\n\nPress the enter key to exit.")

# can you make it better?
