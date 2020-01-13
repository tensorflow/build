import os
import hashlib
import hmac

from flask import Flask, request, abort

import config

app = Flask(__name__)


def verify_github_signature(req):
    reqsig = request.headers.get('X-Hub-Signature')
    data = request.get_data()

    secret = os.environ.get('GITHUB_SECRET', '')
    if not reqsig.startswith("sha1=") or len(secret) < 1:
        abort(401, 'Unauthorized')

    reqsig = reqsig[len("sha1="):]
    secret = secret.encode('utf-8')

    digest = hmac.new(secret, data, hashlib.sha1).hexdigest()

    print("Validate Github Sig: digest:", digest, "request:", reqsig)
    return hmac.compare_digest(digest, reqsig)


@app.route('/', methods=['GET', 'POST'])
def root():
    if request.method != 'POST':
        return '', 204

    # Fail if the sig does not match
    if not verify_github_signature(request):
        abort(401, 'Unauthorized')

    data = request.get_json()
    if not data:
        abort(404, 'JSON request not found')

    # Only accept 'push' events for now
    event = request.headers.get('X-GitHub-Event')
    if event not in config.ALLOWED_EVENTS:
        abort(404, 'GitHub Event not found')

    # Only accept known repos
    if data['repository']['full_name'] not in config.ALLOWED_REPOS:
        abort(404, 'Invalid repo')

    # return the data back to the Tekton event listener
    return data


if __name__ == '__main__':
    print("Running flask webhook app")
    app.run(host="0.0.0.0", port=config.PORT, debug=config.DEBUG_MODE, load_dotenv=False)

