import sqlite3

#conn = sqlite3.connect('student3.db')
conn = sqlite3.connect(':memory:')
c = conn.cursor()

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
#c.execute("INSERT INTO Student VALUES ('Eric', 'Xiao', 13, 'Dublin')")

c.execute("SELECT * FROM Student WHERE first='Eric'")

#c.execute("SELECT * FROM Student ")

print("")
# print(c.fetchmany(1))
print(c.fetchall())

#print("Get studuent who are from Pleasanton:")

#c.execute("SELECT distinct(count(first)) as first FROM Student where first  = 'Eric'")
#print("Total number of studuent who are from Pleasanton:")

#c.execute("SELECT count(*) FROM Student where city = 'Pleasanton'")
print(c.fetchall())

#c.fetchall()
#conn.commit()
conn.commit()

#
# Outout:
# [('Iris', 'Shen', 12.5, 'Pleasanton'), ('Jason', 'Zhang', 15, 'Pleasanton'), ('Kelly', 'Feng', 14, 'Pleasanton'), ('Eric', 'Xiao', 13, 'Dublin')]
# Get studuent who are from Pleasanton:
# Total number of studuent who are from Pleasanton:
# [(3,)]

