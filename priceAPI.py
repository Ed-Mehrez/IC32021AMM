# import sys
import json
# import numpy as np
# import subprocess

from flask import Flask, request, jsonify, json
# from flask_cors import CORS, cross_origin
from werkzeug.exceptions import HTTPException

version = 'IC3'
apiURL = f'/api/v{version}'
app = Flask(__name__)
# cors = CORS(app)
# app.config['CORS_HEADERS'] = 'Content-Type'

from web3 import Web3 # needed if we process response from enclave 'here'
from decimal import Decimal

@app.errorhandler(HTTPException)
def handle_exception(e):
    """Return JSON instead of HTML for HTTP errors."""
    # start with the correct headers and status code from the error
    response = e.get_response()
    # replace the body with JSON
    response.data = json.dumps({
        "code": e.code,
        "name": e.name,
        "description": e.description,
    })
    response.content_type = "application/json"
    return response

def createRequestURL(endpoint):
	return apiURL + endpoint

# Handle request for price
@app.route(createRequestURL('/request-price'), methods=['GET'])
def processPriceRequest():
	expiration = request.args.get('expiration')

    # dump variables to file for enclave to access

    # tell enclave to compute BSM

    # enclave sends results to chain (can send back 'here' first if needed, in which case import web3, contract ABIs)

	# return jsonify()

# Run server on local machine
if __name__ == '__main__':
	app.jinja_env.cache = {}
	app.run(host='127.0.0.1', port=6500)