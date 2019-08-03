# input - Bad
# Demonstrates a logical error

print(
"""
            expense for school

Totals your monthly spending to go to school.

Please enter the requested, monthly costs.  Can ignore pennies and use only dollar amounts.

"""
)

tuition =  input("tuition fee: $")
books = input("books: $")
supplies = input("pens, notebooks etc: $")
food = input("lunch: $")

total = tuition + books + supplies + food

print("\nGrand Total: $", total)
