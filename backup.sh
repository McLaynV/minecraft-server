#!/usr/bin/env bash

message="$(date +'%F %T') ${*}"
echo "${message}"

git add .
git commit -a -m "${message}"
git push

echo ""
