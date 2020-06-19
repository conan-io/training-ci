#!/bin/bash

# bootstrap jenkins

# param 1: Artifactory password
# param 2: Jenkins administrator password

permission=conan-ci2
user=conan
password="conan2020"
address="jfrog.local"
artifactory_pass=$1
jenkins_pass=$2

if [[ $# -ne 2 ]] ; then
    echo 'Please provide passwords for Artifactory and Jenkins. You will find them in your orbitera e-mail.'
    exit 1
fi

echo "------ Artifactory configuration ------"

curl -uadmin:${artifactory_pass} -XPOST http://${address}/artifactory/api/security/groups/readers -d '{"autoJoin":"false"}' -H "Content-Type: application/json"

echo "create repo"
sed "s/<REPO_NAME>/conan-tmp/" templates/create_repo.json | sed "s/<REPO_TYPE>/conan/" | sed "s/<REPO_LAYOUT>/conan-default/" > conan-tmp.json
sed "s/<REPO_NAME>/conan-develop/" templates/create_repo.json | sed "s/<REPO_TYPE>/conan/" | sed "s/<REPO_LAYOUT>/conan-default/" > conan-develop.json
sed "s/<REPO_NAME>/conan-metadata/" templates/create_repo.json | sed "s/<REPO_TYPE>/generic/" | sed "s/<REPO_LAYOUT>/simple-default/" > conan-metadata.json

sed "s/<REPO_NAME>/app-debian-sit-local/" templates/create_repo.json | sed "s/<REPO_TYPE>/debian/" | sed "s/<REPO_LAYOUT>/simple-default/" > debian-sit.json
sed "s/<REPO_NAME>/app-debian-uat-local/" templates/create_repo.json | sed "s/<REPO_TYPE>/debian/" | sed "s/<REPO_LAYOUT>/simple-default/" > debian-uat.json

curl -uadmin:${artifactory_pass} -XPUT http://${address}/artifactory/api/repositories/conan-tmp -T conan-tmp.json -H "Content-Type: application/json"
curl -uadmin:${artifactory_pass} -XPUT http://${address}/artifactory/api/repositories/conan-develop -T conan-develop.json -H "Content-Type: application/json"
curl -uadmin:${artifactory_pass} -XPUT http://${address}/artifactory/api/repositories/conan-metadata -T conan-metadata.json -H "Content-Type: application/json"

curl -uadmin:${artifactory_pass} -XPUT http://${address}/artifactory/api/repositories/app-debian-sit-local -T debian-sit.json -H "Content-Type: application/json"
curl -uadmin:${artifactory_pass} -XPUT http://${address}/artifactory/api/repositories/app-debian-uat-local -T debian-uat.json -H "Content-Type: application/json"

echo "create user"
sed "s/<USER>/${user}/" templates/create_user.json | sed "s/<PASSWORD>/${password}/" > user.json
curl -uadmin:${artifactory_pass} -XPUT http://${address}/artifactory/api/security/users/${user} -T user.json -H "Content-Type: application/json"

echo "create permission"
sed "s/<USER>/${user}/" templates/create_permission.json | sed "s/<NAME>/${permission}/"  | sed "s/<REPO1>/conan-tmp/"| sed "s/<REPO2>/conan-develop/" | sed "s/<REPO3>/conan-metadata/"| sed "s/<REPO4>/app-debian-sit-local/" | sed "s/<REPO5>/app-debian-uat-local/"  > permission.json
curl -uadmin:${artifactory_pass} -XPUT http://${address}/artifactory/api/v2/security/permissions/${permission} -T permission.json -H "Content-Type: application/json"

echo "------ Conan client configuration ------"

conan config install https://github.com/conan-ci-cd-training/settings.git

conan user -p ${password} -r conan-develop ${user}
conan user -p ${password} -r conan-tmp ${user}

git config --global user.email "you@example.com"
git config --global user.name "Your Name"

echo "------ Set labs scripts permission ------"

find .. -name "*.sh" -exec chmod +x {} \;

echo "------ Jenkins configuration ------"

conan_build_info --v2 start conan-app 1

docker exec -it jenkins /bin/bash -c "curl https://raw.githubusercontent.com/conan-io/training-ci/master/setup_jenkins/init_jenkins.sh -O;chmod +x init_jenkins.sh;./init_jenkins.sh ${artifactory_pass} ${jenkins_pass}"

