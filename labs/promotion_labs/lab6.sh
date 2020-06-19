#!/bin/bash

# lab6: configure the JFrog CLI

jfrog rt c --interactive=false  --url=http://jfrog.local:8081/artifactory --user=conan --password=conan2020 art7 

# show current art7 profile
jfrog rt c show

# test connection by listing the repo content
jfrog rt search conan-metadata/
