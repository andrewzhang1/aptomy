import sqlite3

conn = sqlite3.connect('employee.db')

c = conn.cursor()

c.execute(""""CREATE TABKE employees""")