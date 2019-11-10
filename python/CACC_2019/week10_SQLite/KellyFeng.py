import sqlite3
#conn = sqlite3.connect(':memory:')
conn = sqlite3.connect('KellyFeng.db')
c = conn.cursor()
c.execute(""" CREATE TABLE Student (
                first text,
                last text,
                age integer, 
                city text
                )""")
c.execute("INSERT INTO Student VALUES ('Iris', 'Shen', 12, 'Dublin')")
c.execute("INSERT INTO Student VALUES ('Nina', 'Tsai', 13, 'Pleasanton')")
c.execute("INSERT INTO Student VALUES ('Abi', 'Leir', 14, 'Dublin')")
c.execute("INSERT INTO Student VALUES ('Kelly', 'Feng', 13, 'Pleasanton')")
c.execute("SELECT * FROM Student WHERE first = 'Nina'")

c.execute("SELECT * FROM Student ")

print("")
print(c.fetchall())
print ("Get students who are from Dublin:")
c.execute("SELECT * FROM Student where city = 'Dublin'")
print("Total number of students who are from Dublin:")

c.execute("SELECT count (*) FROM Student where city = 'Dublin'")
print(c.fetchall())
conn.commit()
conn.commit()