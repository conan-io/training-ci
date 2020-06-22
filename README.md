# training-ci
Material for advanced CI/CD trainings

All the code is in the organization: https://github.com/conan-ci-cd-training

# Running in the Orbitera instance:

ssh conan@<orbitera-IP>
# Use password from orbitera 

git clone https://github.com/conan-io/training-ci.git

cd conan_ci_cd/setup_jenkins

./bootstrap.sh <artifactory_password> <jenkins_credential>
