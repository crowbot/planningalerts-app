#!/usr/bin/env bash

export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

sudo apt-get update

sudo apt-get install curl git libxslt-dev libxml2-dev proj libpq-dev postgresql -y

# sphinx
sudo apt-get install sphinxsearch -y

# redis prereqs
sudo apt-get install tcl8.5 -y


#install rvm
# TODO: Needs Jones truncation armour, currently fails if used: http://drj11.wordpress.com/2014/03/19/piping-into-shell-may-be-harmful/

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source .bash_profile

rvm install 2.0.0-p648

cd /vagrant
gem install bundler
bundle install
