# import sys
import json
# import numpy as np
# import subprocess
import os

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
@app.route(createRequestURL('/request-price'), methods=['POST'])
def processPriceRequest():
    data = request.get_json(force=True)

    expiration = data['expiration'] #! Needs to be days to expiration
    currentStockPrice = data['current_stock_price']
    strike = data['strike']
    sigma = data['sigma'] # Underlier volatility

    # dump variables to file for enclave to access
    with open("enclave_bsm_input.txt", "w") as inputs:
        inputs.write(f'{expiration},{currentStockPrice},{strike},0,{sigma}')

    # Run secure BSM computation
    os.system(
        "./sgx/app/app --sign \\\n"
        "--enclave-path `pwd`/sgx/enclave/enclave.signed.so \\\n"
        "--sealedprivkey sealedprivkey.bin \\\n"
        "--signature bsm.signature \\\n"
        "--output-file bsm.out \\\n"
        "./enclave_bsm_input"
    ) # Might want to use subprocess for more options

    # enclave sends results to chain (can send back 'here' first if needed, in which case import web3, contract ABIs)
    with open('enclave_bsm_output.txt', 'r') as outputs:
        return jsonify({ "outputs": outputs.read() })

# Run server on local machine
if __name__ == '__main__':
	app.jinja_env.cache = {}
	app.run(host='127.0.0.1', port=6500)
