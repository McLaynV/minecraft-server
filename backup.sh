#!/usr/bin/env bash

sleep 5 # let the server finish

message="$(date +'%F %T') ${*}"
echo "${message}"

git add .
git commit -a -m "${message}"
git push

echo ""
