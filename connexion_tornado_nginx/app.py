from app_business_logic import fetch_value


def test(ident):
    response = fetch_value(ident)
    return response


if __name__ == '__main__':
    from argparse import ArgumentParser
    from os.path import abspath
    from os.path import dirname
    from os.path import join

    from connexion import App

    parser = ArgumentParser(__doc__)
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', default=8080, type=int)
    parser.add_argument('--server', default='tornado')
    parser.add_argument('--api', default=abspath(join(dirname(__file__), 'api.yaml')))
    args = parser.parse_args()

    app = App(__name__)
    app.add_api(args.api)
    app.run(host=args.host, port=args.port, server=args.server)
