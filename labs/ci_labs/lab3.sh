#!/bin/bash

cd /ci_labs 
# Get the revision list from the server (just for the lab, not made by the CI) and get the latest revision
conan search libB/1.0@mycompany/stable -r conan-tmp --revisions

# Download the recipe of the created revision of libB from conan-tmp
conan download libB/1.0@mycompany/stable#put_the_correct_rrev_here -r conan-tmp --recipe

# Get the lockfile of the product we want to check getting the dependencies from conan-develop
conan graph lock App/1.0@mycompany/stable --profile=debug-gcc6 --lockfile=App.lock -r conan-develop

# Calculate the build-order with the lockfile: if the build-order is empty, the product is not affected
conan graph build-order App.lock --json=bo.json --build missing

cat bo.json
