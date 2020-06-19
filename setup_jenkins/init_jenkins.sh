#!/bin/bash

# bootstrap jenkins

# param 1: Artifactory password
# param 2: Jenkins administrator password

address="jfrog.local"
artifactory_pass=$1
jenkins_pass=$2

echo "Config git"

git config --global user.email "you@example.com"
git config --global user.name "Your Name"

echo "Configure conan"

conan config install https://github.com/conan-ci-cd-training/settings.git

echo "Clone libraries"

mkdir /var/lib/jenkins/git_server

cd /var/lib/jenkins/git_server

git clone --bare https://github.com/conan-ci-cd-training/libA.git
git clone --bare https://github.com/conan-ci-cd-training/libB.git
git clone --bare https://github.com/conan-ci-cd-training/libC.git
git clone --bare https://github.com/conan-ci-cd-training/libD.git
git clone --bare https://github.com/conan-ci-cd-training/App.git
git clone --bare https://github.com/conan-ci-cd-training/App2.git
git clone --bare https://github.com/conan-ci-cd-training/products.git
git clone --bare https://github.com/conan-ci-cd-training/release.git

cat << 'EOL' > /var/lib/jenkins/git_server/libA.git/hooks/post-receive
#!/bin/sh

curl http://jfrog.local:8080/git/notifyCommit?url=/var/lib/jenkins/git_server/libA.git
EOL

cat << 'EOL' > /var/lib/jenkins/git_server/libB.git/hooks/post-receive
#!/bin/sh

curl http://jfrog.local:8080/git/notifyCommit?url=/var/lib/jenkins/git_server/libB.git
EOL

cat << 'EOL' > /var/lib/jenkins/git_server/libC.git/hooks/post-receive
#!/bin/sh

curl http://jfrog.local:8080/git/notifyCommit?url=/var/lib/jenkins/git_server/libC.git
EOL

cat << 'EOL' > /var/lib/jenkins/git_server/libD.git/hooks/post-receive
#!/bin/sh

curl http://jfrog.local:8080/git/notifyCommit?url=/var/lib/jenkins/git_server/libD.git
EOL

cat << 'EOL' > /var/lib/jenkins/git_server/App.git/hooks/post-receive
#!/bin/sh

curl http://jfrog.local:8080/git/notifyCommit?url=/var/lib/jenkins/git_server/App.git
EOL

cat << 'EOL' > /var/lib/jenkins/git_server/App2.git/hooks/post-receive
#!/bin/sh

curl http://jfrog.local:8080/git/notifyCommit?url=/var/lib/jenkins/git_server/App2.git
EOL

chmod +x /var/lib/jenkins/git_server/libA.git/hooks/post-receive
chmod +x /var/lib/jenkins/git_server/libB.git/hooks/post-receive
chmod +x /var/lib/jenkins/git_server/libC.git/hooks/post-receive
chmod +x /var/lib/jenkins/git_server/libD.git/hooks/post-receive
chmod +x /var/lib/jenkins/git_server/App.git/hooks/post-receive
chmod +x /var/lib/jenkins/git_server/App2.git/hooks/post-receive

mkdir /workdir
mkdir /ci_labs
mkdir /dev_labs
mkdir /promotion_labs
mkdir /promotion_labs/automation

curl -o /ci_labs/lab3.sh https://raw.githubusercontent.com/conan-io/training-ci/master/labs/ci_labs/lab3.sh
curl -o /ci_labs/lab4.sh https://raw.githubusercontent.com/conan-io/training-ci/master/labs/ci_labs/lab4.sh

curl -o /dev_labs/lab1.sh https://raw.githubusercontent.com/conan-io/training-ci/master/labs/dev_labs/lab1.sh
curl -o /dev_labs/lab2.sh https://raw.githubusercontent.com/conan-io/training-ci/master/labs/dev_labs/lab2.sh
curl -o /dev_labs/lab5.sh https://raw.githubusercontent.com/conan-io/training-ci/master/labs/dev_labs/lab5.sh

curl -o /promotion_labs/lab6.sh https://raw.githubusercontent.com/conan-io/training-ci/master/labs/promotion_labs/lab6.sh
curl -o /promotion_labs/lab7.sh https://raw.githubusercontent.com/conan-io/training-ci/master/labs/promotion_labs/lab7.sh
curl -o /promotion_labs/lab8.sh https://raw.githubusercontent.com/conan-io/training-ci/master/labs/promotion_labs/lab8.sh
curl -o /promotion_labs/lab9.sh https://raw.githubusercontent.com/conan-io/training-ci/master/labs/promotion_labs/lab9.sh
curl -o /promotion_labs/lab10.sh https://raw.githubusercontent.com/conan-io/training-ci/master/labs/promotion_labs/lab10.sh
curl -o /promotion_labs/generateDebianPkg.sh https://raw.githubusercontent.com/conan-io/training-ci/master/labs/promotion_labs/generateDebianPkg.sh

curl -o /promotion_labs/automation/filespec.json https://raw.githubusercontent.com/conan-io/training-ci/master/labs/promotion_labs/automation/filespec.json
curl -o /promotion_labs/automation/query.aql https://raw.githubusercontent.com/conan-io/training-ci/master/labs/promotion_labs/automation/query.aql

find /ci_labs -name "*.sh" -exec chmod +x {} \;
find /dev_labs -name "*.sh" -exec chmod +x {} \;
find /promotion_labs -name "*.sh" -exec chmod +x {} \;

cd /workdir

git clone /var/lib/jenkins/git_server/libA.git
git clone /var/lib/jenkins/git_server/libB.git
git clone /var/lib/jenkins/git_server/libC.git
git clone /var/lib/jenkins/git_server/libD.git
git clone /var/lib/jenkins/git_server/App.git
git clone /var/lib/jenkins/git_server/App2.git

conan export libA mycompany/stable
conan export libB mycompany/stable
conan export libC mycompany/stable
conan export libD mycompany/stable
conan export App mycompany/stable
conan export App2 mycompany/stable

conan user -p ${artifactory_pass} -r conan-develop admin
conan user -p ${artifactory_pass} -r conan-tmp admin

conan upload '*' -r conan-develop --all --confirm
conan upload '*' -r conan-tmp --all --confirm

rm -rf /workdir/libA
rm -rf /workdir/libC
rm -rf /workdir/libD
rm -rf /workdir/App
rm -rf /workdir/App2

cd /var/lib/jenkins

echo "------ Create libraries with DEBUG profile ------"
docker run --network="host" -it conanio/gcc6 /bin/bash -c "sudo mkdir -p /var/lib/jenkins/git_server && cd /var/lib/jenkins/git_server && sudo git clone --bare https://github.com/conan-ci-cd-training/libA.git && sudo git clone --bare https://github.com/conan-ci-cd-training/libB.git && sudo git clone --bare https://github.com/conan-ci-cd-training/libC.git && sudo git clone --bare https://github.com/conan-ci-cd-training/libD.git && sudo git clone --bare https://github.com/conan-ci-cd-training/App.git && sudo git clone --bare https://github.com/conan-ci-cd-training/App2.git && conan config install https://github.com/conan-ci-cd-training/settings.git;conan user -p ${artifactory_pass} -r conan-develop admin;conan user -p ${artifactory_pass} -r conan-tmp admin;conan install App/1.0@mycompany/stable --profile debug-gcc6 --build missing -r conan-develop;conan install App2/1.0@mycompany/stable --profile debug-gcc6 --build missing -r conan-develop;conan upload '*' --all -r conan-develop --confirm;conan upload '*' --all -r conan-tmp --confirm"
echo "------ Create libraries with RELEASE profile ------"
docker run --network="host" -it conanio/gcc6 /bin/bash -c "sudo mkdir -p /var/lib/jenkins/git_server && cd /var/lib/jenkins/git_server && sudo git clone --bare https://github.com/conan-ci-cd-training/libA.git && sudo git clone --bare https://github.com/conan-ci-cd-training/libB.git && sudo git clone --bare https://github.com/conan-ci-cd-training/libC.git && sudo git clone --bare https://github.com/conan-ci-cd-training/libD.git && sudo git clone --bare https://github.com/conan-ci-cd-training/App.git && sudo git clone --bare https://github.com/conan-ci-cd-training/App2.git && conan config install https://github.com/conan-ci-cd-training/settings.git;conan user -p ${artifactory_pass} -r conan-develop admin;conan user -p ${artifactory_pass} -r conan-tmp admin;conan install App/1.0@mycompany/stable --profile release-gcc6 --build missing -r conan-develop;conan install App2/1.0@mycompany/stable --profile release-gcc6 --build missing -r conan-develop;conan upload '*' --all -r conan-develop --confirm;conan upload '*' --all -r conan-tmp --confirm"

echo "------ Configure Jenkins jobs ------"

rm -rf /var/lib/jenkins/jobs/maven-pipeline/
rm -rf /var/lib/jenkins/jobs/maven-promotion/

curl https://raw.githubusercontent.com/conan-io/training-ci/master/setup_jenkins/jenkins_jobs.tgz -O

tar -xvf jenkins_jobs.tgz --directory /var/lib/jenkins/jobs

echo "------ Restart Jenkins ------"

echo "--------------------------------"
echo "------ FINISHED BOOTSTRAP ------"
echo "--------------------------------"

curl -X POST -u administrator:${jenkins_pass} http://${address}:8080/restart
