#!/bin/bash

apt-get update

#
# Erlang 20.3
#
apt-get install -y curl automake autoconf libncurses5-dev gcc build-essential \
	libssl1.0.2=1.0.2l-2+deb9u2 libssl1.0-dev
curl -O https://raw.githubusercontent.com/kerl/kerl/master/kerl
chmod a+x kerl
mv kerl /usr/local/bin
kerl build 20.3 20.3
kerl install 20.3 ~/kerl/20.3
. /root/kerl/20.3/activate

#
# rebar3
#
wget https://s3.amazonaws.com/rebar3/rebar3 && chmod +x rebar3
mv rebar3 /usr/local/bin/

#
# elixir 1.6
#
curl -O https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
dpkg -i erlang-solutions_1.0_all.deb
apt-get install elixir=1.6.1-1

#
# postgresql 10.4
#

apt-get install -y libreadline-dev zlib1g-dev libbison-dev libfl-dev 
curl -O https://ftp.postgresql.org/pub/source/v10.4/postgresql-10.4.tar.bz2
tar xvjf postgresql-10.4.tar.bz2
cd postgresql-10.4/
./configure
make
make install
PATH=/usr/local/pgsql/bin/:$PATH


#
# Docker
#
sudo apt-get install -y apt-transport-https ca-certificates gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
echo "deb [arch=armhf] https://download.docker.com/linux/debian \
     $(lsb_release -cs) stable" | \
        tee /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce=17.12.1~ce-0~debian

#
# Docker compose
#
apt-get -y install python-pip
pip install docker-compose

#
# Nodejs
#
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
apt-get install -y build-essential libuv1=1.18.0-3~bpo9+1 nodejs=10.6.0-1nodesource1
