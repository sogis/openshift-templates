# Deploying Matomo in OpenShift

## Create and configure project

Create project
```
oc new-project my-namespace
```

Set secret for pulling images from image registry (optional)
```
oc create secret docker-registry dockerhub-pull-secret --docker-username=xy --docker-password=xy -n my-namespace
oc secrets link default dockerhub-pull-secret --for=pull -n my-namespace
```

Grant permissions for deploying the app
from a Jenkins instance running in a different namespace (optional);
replace JENKINS-NAMESPACE with the name of the namespace
where Jenkins is deployed
```
oc policy add-role-to-user edit system:serviceaccount:JENKINS-NAMESPACE:jenkins -n my-namespace
```

Grant permissions on project (optional)
```
oc policy add-role-to-user admin ... -n my-namespace
oc policy add-role-to-user view ... -n my-namespace
```

## Apply template for matomo
Please install the mariadb Database first (https://jenkins-agi-apps-production.apps.ocp.so.ch/job/agi-infrastructure/job/mariadb/) before installing the matomo app.

The matomo.yaml file is from the github repository of Tobias Brunner. Get it by git clone https://github.com/tobru/piwik-openshift.git.
Before installing matomo you need a pvc named app-config.
```
oc process -f matomo/matomo.yaml --param-file=matomo/matomo_test.params | oc apply -f - -n my-namespace
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
Don't forget to save the adjustmen
