#!/bin/bash

## lab10: build Info Promotion 

jfrog rt bpr debian-app 1 app-debian-uat-local --status="SIT_OK"  --comment="passed integration tests" --include-dependencies=false --copy=false
