#!/usr/bin/env python3

import requests
import hashlib
import hmac
import os
import sys


# forward to listener with:
# kubectl port-forward svc/el-build-listener 7070:8080 --namespace=sig-build
HOOKURL = 'http://localhost:7070/'

DATA = {
    "head_commit":
    {
        "id": "master"
    },
    "repository":
    {
        "full_name": "perfinion/build",
        "branch": "master"
    }

}


############################################

secret = os.environ.get('GITHUB_SECRET', '')
if len(secret) < 1:
    print('Set env var GITHUB_SECRET')
    sys.exit(1)

request = requests.Request('POST', HOOKURL, data=DATA)
prepped = request.prepare()

sig = hmac.new(secret, prepped.body, hashlib.sha1)
prepped.headers['X-Hub-Signature'] = "sha1=%s" % sig.hexdigest()

with requests.Session() as session:
    response = session.send(prepped)

