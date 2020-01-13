#!/usr/bin/env python3

import requests
import hashlib
import hmac
import os
import sys

from pprint import pprint


# forward to listener with:
# kubectl port-forward svc/el-build-listener 7070:8080 --namespace=sig-build
HOOKURL = 'https://tfbuild.perfinion.com/webhook/'

HEADERS = {
    'X-GitHub-Event': 'push',
}

DATA = {
    "head_commit":
    {
        "id": "master"
    },
    "repository":
    {
        "name": "build",
        "full_name": "perfinion/build",
        "owner":
        {
            "name": "perfinion",
        },
    }

}


############################################

secret = os.environ.get('GITHUB_SECRET', '')
if len(secret) < 1:
    print('Set env var GITHUB_SECRET')
    sys.exit(1)

secret = secret.encode('utf-8')

request = requests.Request('POST', HOOKURL, headers=HEADERS, json=DATA)
prepped = request.prepare()

sig = hmac.new(secret, prepped.body, hashlib.sha1)
prepped.headers['X-Hub-Signature'] = "sha1=%s" % sig.hexdigest()

with requests.Session() as session:
    r = session.send(prepped)

print("Response status code:", r.status_code)
print("Response headers:")
pprint(r.headers)
print("\nResponse text:")
print(r.text)

