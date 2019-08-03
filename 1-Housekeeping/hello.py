from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, World!'


# /mnt/AGZ1/GD_AGZ1117/AGZ_Home/workspace_pOD/1_HouseKeeper
# (azhang@vmlxu1)\>FLASK_APP=hello.py flask run
