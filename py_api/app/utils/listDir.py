from flask_restful import Resource

class ListDir(Resource):
    def get(self):
        return {'about':'Hello World'}
    
#     def post(self):
#         # some_json = request.get_json()
#         return {'you_sent': 'asd'}, 201