# Deploying MariaDB in OpenShift

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

## Create secret

In a separate folder, create a file `mariadb-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/mariadb-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: mariadb-secret
  labels:
    app: mariadb
stringData:
  database-name: xy
  database-password: xy
  database-root-password: xy
  database-user: xy
```

## Apply template for mariaDB
Because of the .snapshot directory in the persistent volume it is not possible to use the in openshift included mariadb template directly. 
A few changes in the template are necessary: First you have to change the my.cnf file and add ignore-db-dirs = .snapshot.
Make a configMap from the my.cnf file add it to the template and add the mount for the configMap to /etc/mysql. Thereby mariadb knows where to find the my.cfg file 
you have to set an additional ENV variable MYSQL_DEFAULTS_FILE in the template.

```
oc process -f matomo/mariadb.yaml --param-file=matomo/mariadb_integration.params | oc apply -f - -n my-namespace
```
