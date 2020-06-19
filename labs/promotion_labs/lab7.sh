#!/bin/bash

## lab7: download App based on properties

# show filespec based on AQL
cat automation/filespec.json

# download lockfile based on properties + output “success”
jfrog rt download --spec=automation/filespec.json 

# “deploy” the package referenced in the lockfile in the current path
conan install App/1.0@mycompany/stable --lockfile app_release.lock -g deploy -r conan-develop
ls -l App/ 

# execute the deployed App 
./App/bin/App

