#!/bin/bash

# find path to conan_package.tgz
version=`jfrog rt curl -XPOST -T automation/query.aql api/search/aql | grep value | cut -d: -f2| cut -d\" -f2`

# generate debian package
rm -rf debian_gen
mkdir -p debian_gen/myapp_${version}/{DEBIAN,var}
mkdir -p debian_gen/myapp_${version}/var/myapp

cat << 'EOL' >> debian_gen/myapp_${version}/DEBIAN/control
Package: app
Architecture: all
Maintainer: Yann Chaysinh
Priority: optional
Version: <VERSION>
Description: My Simple Debian package to deploy App
EOL

sed -i "s/<VERSION>/${version}/" debian_gen/myapp_${version}/DEBIAN/control

cp App/bin/App debian_gen/myapp_${version}/var/myapp/

dpkg-deb --build debian_gen/myapp_${version}

dpkg -c debian_gen/myapp_${version}.deb

# upload debian package
curl -u$1:$2 -XPUT "http://jfrog.local:8081/artifactory/app-debian-sit-local/pool/myapp_${version}.deb;deb.distribution=stretch;deb.component=main;deb.architecture=x86-64" -T debian_gen/myapp_${version}.deb 

