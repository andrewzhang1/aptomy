from sqlalchemy import create_engine
from sqlalchemy import Column, String, Integer, Date
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# from base import Base


from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

engine = create_engine("sqlite:///test_db.db")

#from pdb import set_trace; set_trace()

session = sessionmaker(bind=engine)()

# Need to connect to the database, provide some
Base = declarative_base()

# How to define the table:

class User(Base):

    __tablename__ = "user"

    # Tell what columns inside
    username = Column(String, primary_key=True)
    password = Column(String)

    def __init__(self, username, password):
        self.username = username
        self.password = password

user = User("daniel", "some_password")

session.add(user)
session.commit()

