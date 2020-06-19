#!/bin/bash

## lab1: the developer creates a feature branch, makes some changes and pushes

cd /workdir/libB

git checkout -b cool_feature

echo "// modify libB source" >> src/libB.cpp

git commit -a -m "commit cool feature"

git push origin cool_feature