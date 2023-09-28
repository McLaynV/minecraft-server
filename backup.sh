#!/usr/bin/env bash

sleep 5 # let the server finish

cd "$(dirname "${0}")"

message="$(date +'%F %T') ${*}"
echo "${message}"

git add .
echo "Add exited ${?}"
git commit -a -m "${message}"
echo "Commit exited ${?}"
git push
echo "push exited ${?}"

echo ""
