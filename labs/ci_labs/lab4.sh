#!/bin/bash

## lab4: build App using lockfiles and build order

cat bo.json

cp App.lock conan.lock

conan install libD/1.0@mycompany/stable --build libD --lockfile conan.lock

cp conan.lock libD.lock
 
# the install marked libD as modified=”built” in the lockfile
cat libD.lock

# we bring those changes to App.lock and continue iterating until we build all the nodes in bo.json
conan graph update-lock App.lock libD.lock

cat App.lock
