from flask import Flask
from flask_restful import Api
from utils.createJson import CreateJson
from utils.listDir import ListDir
from utils.systemInfo import SystemInfo

app = Flask(__name__)
api = Api(app)

api.add_resource(CreateJson, '/createJson', '/Foo/<string:id>')
api.add_resource(SystemInfo, '/system', '/Foo/<string:id>')
api.add_resource(ListDir, '/listDir', '/Foo/<string:id>')

if __name__ == '__main__':
    app.run(debug=True, port=5000,host='0.0.0.0')