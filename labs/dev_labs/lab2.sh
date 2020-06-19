#!/bin/bash

## lab2: the developer creates a PR to develop and pushes some changes

git checkout -b PR-01

echo "# Comments in the conanfile.py" >> conanfile.py

git commit -a -m "simulating a PR to develop"

git push origin PR-01
