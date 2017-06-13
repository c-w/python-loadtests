from sanic import Sanic
from sanic.response import json

from app_business_logic import fetch_value

app = Sanic(__name__)


@app.route('/test/<ident>')
async def test(request, ident):
    response = fetch_value(ident)
    return json(response)


if __name__ == '__main__':
    from argparse import ArgumentParser
    from multiprocessing import cpu_count

    parser = ArgumentParser(__doc__)
    parser.add_argument('--host', default='0.0.0.0')
    parser.add_argument('--port', default=80, type=int)
    parser.add_argument('--workers', default=cpu_count(), type=int)
    args = parser.parse_args()

    app.run(host=args.host, port=args.port, workers=args.workers)
