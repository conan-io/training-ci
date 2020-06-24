#!/bin/bash

## lab9: create a custom Build info

# define “artifact section” in build info
# won’t be re-uploaded as the JFrog CLI is checksum aware => output “status”:“success”
jfrog rt u debian_gen/myapp_1.0.deb app-debian-sit-local/pool/ --build-name=debian-app --build-number=1

# define “dependency section” in build info => output “status”:“success”
jfrog rt bad debian-app 1 App-release-gcc6.lock

# publish build info => check result in Artifactory in the build section
jfrog rt bp debian-app 1
