import sqlite3

conn = sqlite3.connect('employee1.db')

c = conn.cursor()

c.execute(""""CREATE TABLE employees1 (
    first text,
    last text,
    pay integer
    )""" )


conn.commit()
conn.close()
