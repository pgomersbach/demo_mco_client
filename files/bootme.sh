#!/usr/bin/env bash
#
# This script installs puppet 3.x or 4.x and deploy the manifest using puppet apply -e "include demo_mco_client"
#
# Usage:
# Ubuntu / Debian: wget https://raw.githubusercontent.com/pgomersbach/demo_mco_client/master/files/bootme.sh; bash bootme.sh
#
# Red Hat / CentOS: curl https://raw.githubusercontent.com/pgomersbach/demo_mco_client/master/skeleton/files/bootme.sh -o bootme.sh; bash bootme.sh
# Options: add 3 as parameter to install 4.x release

# default major version, comment to install puppet 3.x
PUPPETMAJORVERSION=4

### Code start ###
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if [ "$#" -gt 0 ]; then
   if [ "$1" = 3 ]; then
     PUPPETMAJOR=3
   else
     PUPPETMAJOR=4
  fi
else
  PUPPETMAJOR=$PUPPETMAJORVERSION
fi

if [ "$PUPPETMAJOR" = 3 ]; then
    MODULEDIR="/etc/puppet/modules/"
  else
    MODULEDIR="/etc/puppetlabs/code/modules/"
fi

# install dependencies
if which apt-get > /dev/null 2>&1; then
    apt-get update
  else
    echo "Using yum"
fi

apt-get install git bundler zlib1g-dev -y || yum install -y git bundler zlib-devel

# get or update repo
if [ -d /root/demo_mco_client ]; then
  echo "Update repo"
  cd /root/demo_mco_client
  git pull
else
  echo "Cloning repo"
  git clone https://github.com/pgomersbach/demo_mco_client.git /root/demo_mco_client
  cd /root/demo_mco_client
fi

# install puppet if not installed
if which puppet > /dev/null 2>&1; then
   echo "Puppet is already installed."
  else
    bash /root/demo_mco_client/files/bootstrap.sh $PUPPETMAJOR
fi

# prepare bundle
echo "Installing gems"
bundle install --path vendor/bundle --without development system_tests
# install dependencies from .fixtures
echo "Preparing modules"
bundle exec rake spec_prep
# copy to puppet module location
cp -a /root/demo_mco_client/spec/fixtures/modules/* $MODULEDIR
echo "Run puppet apply"
puppet apply -e "include demo_mco_client"
