# input - Bad
# Demonstrates a logical error

print(
"""
            expense for school

Totals your monthly spending to go to school.

Please enter the requested, monthly costs.  Can ignore pennies and use only dollar amounts.

"""
)

tuition =  int(input("tuition fee: $"))
books = int(input("books: $"))
supplies = int(input("pens, notebooks etc: $"))
food = int(input("lunch: $"))

total = tuition + books + supplies + food

print("\nGrand Total: $", total)
