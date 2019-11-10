import sqlite3

conn = sqlite3.connect('student.db')
#conn = sqlite3.connect(':memory:')
c = conn.cursor()

#1. Can't run twice for the create:
# c.execute(""" CREATE TABLE Employee (
#                 first text,
#                 last text,
#                 pay integer
#                 )""")

c.execute(""" CREATE TABLE Student (
                first text,
                last text,
                age integer,
                city text
                )""")



# 2. Run once too:

c.execute("INSERT INTO Student VALUES ('Iris', 'Shen', 12.5 , 'Pleasanton')")

c.execute("INSERT INTO Student VALUES ('Jason', 'Zhang', 15, 'Pleasanton')")
c.execute("INSERT INTO Student VALUES ('Kelly', 'Feng', 14, 'Pleasanton')")
c.execute("INSERT INTO Student VALUES ('Eric', 'Xiao', 13, 'Dublin')")
c.execute("SELECT * FROM Student WHERE first='Eric'")

c.execute("SELECT * FROM Student ")

print("")
# print(c.fetchmany(1))
print(c.fetchall())

print("\nGet studuent who are from Pleasanton: \n")

c.execute("SELECT * FROM Student where city = 'Pleasanton'")
print("\n Total number of studuent who are from Pleasanton: \n")

c.execute("SELECT count(*) FROM Student where city = 'Pleasanton'")
print(c.fetchall())
#c.fetchall()
conn.commit()

conn.commit()