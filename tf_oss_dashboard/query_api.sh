#!/usr/bin/env bash
#
# Copyright 2023 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================
#
# Usage:
#   export GITHUB_TOKEN=[your github token, see github.com/settings/tokens]
#   query_api.sh config.yaml > dashboard_data.json
#
# Send the dashboard data graphql query (query.graphql) to the GitHub GraphQL
# API, choosing the owner and repository (e.g. tensorflow/tensorflow) from the
# provided config file. You must have a valid GITHUB_TOKEN in the env.
# 
# Requires "yq" and "jq"
#
# See https://docs.github.com/en/graphql/overview/explorer

# Convert config yaml file to json
echo "::group::config.json"
yq -o json . $1 | tee config.json || exit 0
echo "::endgroup::"
# <<'EOF' is a quoted heredoc that allows literal $ signs.
# See https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Here-Documents
# Note that in query.graphql, query($name:String!, $owner:String!) declare that
# those two variables will come along with the query. Format is $name:Type!
echo "::group::script.jq"
tee script.jq <<'EOF'
{
  query: $query,
  variables: {
    owner: .repo_owner,
    name: .repo_name,
    branch: .repo_branch
  }
}
EOF
echo "::endgroup::"
# Generate a well-formed and escaped JSON payload that contains the graphQL
# query and its variables. jq loads the variables for us and also escapes any
# weird symbols.
echo "::group::query.json"
jq --rawfile query query.graphql --from-file script.jq config.json | tee query.json
echo "::endgroup::"
# Note that curl accepts "raw data" or @filename for the --data flag
echo "::group::curl call"
curl https://api.github.com/graphql --request POST \
  --header "Authorization: Bearer $GITHUB_TOKEN" \
  --header "Content-Type: application/json" \
  --data @query.json | tee $2
echo "::endgroup::"
