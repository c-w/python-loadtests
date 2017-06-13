from flask import Flask
from flask import jsonify

from app_business_logic import fetch_value

app = Flask(__name__)


@app.route('/network/<ident>')
def network(ident):
    response = fetch_value(ident)
    return jsonify(response)


@app.route('/echo/<ident>')
def echo(ident):
    return jsonify({'value': ident})


if __name__ == '__main__':
    from argparse import ArgumentParser

    parser = ArgumentParser(__doc__)
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', default=8080, type=int)
    args = parser.parse_args()

    app.run(host=args.host, port=args.port)
