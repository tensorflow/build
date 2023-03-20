#!/bin/bash
set -euxo pipefail

pip install -r requirements.txt

./query_api.sh > new.json
if [[ -e old.json ]]; then
  ./merge.py old.json new.json > merged.json
else
  mv new.json merged.json
fi
cat merged.json | ./dashboard.py > dashboard.html
mv merged.json old.json
