#!/bin/bash

## lab9: create a custom Build info

# define “artifact section” in build info
# won’t be reuploaded as the JFrog CLI is checksum aware
jfrog rt u debian_gen/myapp_1.0.deb app-debian-sit-local/pool/ --build-name=debian-app --build-number=1

# define “dependency section” in build info
jfrog rt bad debian-app 1 app_release.lock
jfrog rt bad debian-app 1 App/conan_package.tgz

# publish build info
jfrog rt bp debian-app 1
