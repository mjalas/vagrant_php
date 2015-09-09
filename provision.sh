#!/usr/bin/env bash

# Variables
APPENV=local
DBHOST=localhost
DBNAME=testing
DBUSER=dev
DBPASSWD=development
DBROOTPASSWD=root

echo "--- Updating repositories and upgrading system... ---"
apt-get update > /dev/null 2>&1
apt-get -y upgrade > /dev/null 2>&1
echo "--- Done. ---"
echo "--- Starting environment setup: ---"

echo "--- Installing base packages... ---"
apt-get -y install curl build-essential git > /dev/null 2>&1
echo "--- Base packages installation complete. ---"

echo "--- Add repos to update distros ---"
add-apt-repository ppa:ondrej/php5 > /dev/null 2>&1

echo "--- Update package list ---"
apt-get update > /dev/null 2>&1

echo "-- Installing MySQL server and client.. ---"
echo "mysql-server mysql-server/root_password password $DBROOTPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBROOTPASSWD" | debconf-set-selections
apt-get -y install mysql-server > 2>&1
echo "--- MySQL installation complete. ---"

echo -e "--- Setting up our MySQL user and db ---"
mysql -uroot -p$DBROOTPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBROOTPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"


echo "--- Installing PHP and Apache2... ---"
apt-get -y install php5 apache2 libapache2-mod-php5  > /dev/null 2>&1
echo "--- Installing PHP development support libraries... ---"
apt-get -y install php5-curl php5-gd php5-mcrypt php5-mysql php5-cli phpunit php5-xdebug php-apc > /dev/null 2>&1

echo -e "--- Enabling mod-rewrite ---"
a2enmod rewrite > /dev/null 2>&1


echo "--- Setting app structure ---"
mkdir /vagrant/app
mkdir /vagrant/share
mkdir /vagrant/app/public
touch /vagrant/app/public/index.php
touch /vagrant/app/public/.htaccess

echo -e "--- Setting document root to public directory ---"
rm -rf /var/www
ln -fs /vagrant/app/public /var/www


echo -e "--- Restarting Apache ---"
service apache2 restart > /dev/null 2>&1

echo -e "\n--- Installing Composer for PHP package management ---\n"
curl --silent https://getcomposer.org/installer | php > /dev/null 2>&1
mv composer.phar /usr/local/bin/composer


echo -e "\n--- Creating a symlink for future phpunit use ---\n"
ln -fs /vagrant/vendor/bin/phpunit /usr/local/bin/phpunit

echo -e "\n--- Add environment variables locally for artisan ---\n"
cat >> /home/vagrant/.bashrc <<EOF
# Set envvars
export APP_ENV=$APPENV
export DB_HOST=$DBHOST
export DB_NAME=$DBNAME
export DB_USER=$DBUSER
export DB_PASS=$DBPASSWD
EOF

echo "Environment setup done."
echo "Happy developing!"