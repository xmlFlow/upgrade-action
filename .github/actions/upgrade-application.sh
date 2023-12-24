#!/bin/bash

mkdir -p files
mkdir -p public
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
#sudo mysql -u root -e "DROP DATABASE IF EXISTS \`${DBNAME}\` ";

