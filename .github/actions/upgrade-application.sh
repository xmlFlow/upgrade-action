#!/bin/bash
set -e
export BASEURL="http://localhost" # This is the URL to the installation directory.
export DBHOST=localhost # Database hostname
export DBNAME=${APPLICATION}-ci # Database name
export DBUSERNAME=${APPLICATION}-ci # Database username
export DBPASSWORD=${APPLICATION}-ci # Database password
export FILESDIR=files # Files directory (relative to application directory -- do not do this in production!)
export DATABASEDUMP=~/database.sql.gz # Path and filename where a database dump can be created/accessed
export FILESDUMP=~/files.tar.gz

cp -r datasets/${APPLICATION}/${DATASET_BRANCH}/${TEST}/files/* files/
cp -r datasets/${APPLICATION}/${DATASET_BRANCH}/${TEST}/public/* public/
cp  datasets/${APPLICATION}/${DATASET_BRANCH}/${TEST}/config.inc.php .
if [[ "${DATASET_BRANCH}" =~ ^(stable-3_2_0|stable-3_2_1|stable-3_3_0)$ ]]; then
  patch -p1 < datasets/upgrade/3_4_0-add-email-config.diff
  patch -p1 < datasets/upgrade/3_4_0-update-locale.diff
fi

./datasets/tools/dbclient.sh < datasets/${APPLICATION}/${DATASET_BRANCH}/${TEST}/database.sql
php tools/upgrade.php check
php tools/upgrade.php upgrade
rm -rf files
rm -rf public
#sudo mysql -u root -e "DROP DATABASE  \`${DBNAME}\` ";
#sudo mysql -u root -e "DROP USER \`${DBUSERNAME}\`@${DBHOST}";

echo "upgrade-finished" >> $GITHUB_STEP_SUMMARY

