#!/bin/bash

## lab5: the PR is merged to develop

git checkout develop

git merge PR-01 --no-ff -m "merge PR-01"

git push origin develop
