#!/bin/bash
# option : Github clone address

if [ $# -ne 1 ]; then
  echo "ERROR : option invalid." 1>&2
  exit 1
fi

dir="report-`date '+%M%S'`"
fedora_socket="/var/lib/mysql/mysql.sock"
debian_socket="/var/run/mysqld/mysqld.sock"
dbyml="config/database.yml"

rm -rf $dir
git clone $1 $dir
cd $dir && pwd
sed -i -e "s|$fedora_socket|$debian_socket|g" $dbyml
sudo service mysql restart
bundle install --without production
rails db:drop RAILS_ENV=development
rails db:create RAILS_ENV=development
rails db:migrate
rails s

read -p " - clean? [y/n] > " YN
if [ "$YN" = "y" ]; then
  cd ../ && pwd
  rm -rf $dir
fi
echo " - Goodbye!"

exit 0
