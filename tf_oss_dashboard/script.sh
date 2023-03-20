#!/bin/bash
set -euxo pipefail

pip install -r requirements.txt

./query_api.sh > new.json
./merge.py old.json new.json > merged.json
cat merged.json ./dashboard.py > dashboard.html
mv merged.json old.json
