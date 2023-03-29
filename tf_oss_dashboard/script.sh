#!/bin/bash
set -euxo pipefail

pip install -r requirements.txt

./query_api.sh > new.json
echo "::group::New Query Data"
cat new.json
echo "::endgroup::"
if [[ -e "../Merged Data/old.json" ]]; then
  mv "../Merged Data/old.json" old.json
  ./merge.py old.json new.json > merged.json
  echo "::group::Merged Data"
  cat merged.json
  echo "::endgroup::"
else
  mv new.json merged.json
fi
echo "::group::Dashboard Generator Output"
cat merged.json | ./dashboard.py | tee dashboard.html
echo "::endgroup::"
mv merged.json old.json
