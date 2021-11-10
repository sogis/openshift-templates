# Matomo

## First install in an Openshift Environment

All necessary components of the application are configured in the openshift template mariadb and in the github repository of Tobias Brunner
The matomo.yaml file is from the github repository of Tobias Brunner. Get it by git clone https://github.com/tobru/piwik-openshift.git
### Install mariadb.
Before installing mariadb in the environment of the cantone of Solothurn you need a mariadb named pvc.
The necessary passwords and usernames are saved in the gdi keepass.
Because of the .snapshot directory in the persistent volume it is not possible to use the in openshift included mariadb template directly.
A few changes in the template are necessary:
First you have to change the my.cnf file and add ignore-db-dirs = .snapshot
Make a configMap from the my.cnf file add it to the template and add the mount for the configMap to /etc/mysql.
Thereby mariadb knows where to find the my.cfg file you have to set an additional ENV variable MYSQL_DEFAULTS_FILE in the template.
```
oc process -f mariadb-persistent.yaml -p MEMORY_LIMIT=2048Mi -p MYSQL_USER=mysql_user -p MYSQL_PASSWORD=mysql_pw -p MYSQL_ROOT_PASSWORD=root_pw -p MYSQL_DATABASE=matomo -p MARIADB_VERSION=10.3 -p VOLUME_CAPACITY=5Gi -p NAMESPACE=agi-infrastructure-integration | oc apply -f-
```

### Install matomo

Before installing matomo in the environment of the cantone of Solothurn you need a pvc named app-config.
The matomo.yaml file is a slightly changed version of the one from tobru repo.
Changes are needed for MATOMO_IMAGE_SOURCE and MATOMO_IMAGE_TAG and for the apiVersion in CronJob.
Then run
```
oc process -f matomo.yaml -p APP_URL=analytics-i.apps.ocp.so.ch | oc apply -f-
```

### Setup matomo
Open http://analytics-i.apps.ocp.so.ch and follow the setup instructions
#### DB Connection
For the IP use the IP address of the mariadb service
Username and password are saved in keepass
DB Name is matomo
#### Hauptadministrator
Login and Password are saved in the keepass
Email use sogis@bd.so.ch
#### Website
Name Web GIS Client
Url geo-i.so.ch

## Update Matomo
To update matomo change parameter MATOMO_IMAGE_TAG in matomo.yaml and run
```
oc process -f matomo.yaml -p APP_URL=analytics-i.apps.ocp.so.ch | oc apply -f-
```
### Comment bjsvwpfe 24.9.2020
With actual version 3.14.1-fpm the cronjob doesn't work anymore. As a workaround added a own builded image to openshift registry (agi-matomo).
In the Image the sourcecode of the default matomo 3.14.1-fpm Image is overwrittnen with downloaded sourcecode from https://builds.matomo.org/matomo.zip.
The agi-matomo image is used in the cronjob.
Hope this could be rolled back with the next version.


It's possible that after the update DBIP/ GeoIP2 Location Provider must be new installed.
To install run from this directory 
```
oc rsync misc/ matomo-pod:/var/www/html/misc
```
Inside the matomo Pod cd to /var/www/html/misc and then run
```
mv dbip-city-lite-2020-01.mmdb DBIP-City.mmdb
```
Login to matomo with gdi-admin user.
Click Preferences/Geolocation and Select DBIP/ GeoIP 2 which should be installed now. 
Don't forget to save the adjustment
