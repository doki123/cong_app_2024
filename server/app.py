from flask import Flask, request
# there's a selection for topics & then one for bill date (one month intervals?); also can filter by congress member 
# python notebook for api testing + filtering, then bring it in and make routes --> get api key and save as variable
# requests library for get/post 
app = Flask("Congressional App")

key = "g51ZVJeu9Te5r14aSLpG86n1BatzwIsnU8CfcVWv"

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'GET':
        return {'message': 'connected to server', 'success': True}
    elif request.method == 'POST':
    #         print('Hello')
    # earth_date = request.json['date']
    # print(earth_date)
    # data = nasa.mars_rover(earth_date=earth_date)
    # print(data)
    # return data

        return ""
    
app.run(debug=True, host="0.0.0.0", port='5001')