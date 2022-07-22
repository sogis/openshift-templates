# Deploying QGIS Server (for seeding WMTS tiles) in OpenShift

## Create and configure project

Create project
```
oc new-project my-namespace
```

Set secret for pulling images from image registry (optional)
```
oc create secret docker-registry dockerhub-pull-secret --docker-username=xy --docker-password=xy -n my-namespace
oc secrets link default dockerhub-pull-secret --for=pull -n my-namespace
oc secrets link qgis-server dockerhub-pull-secret --for=pull -n my-namespace
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

Create Persistent Volume Claims
```
TODO
```

## Special note

This template is based on the template in
https://github.com/sogis/pipelines/tree/master/api_webgisclient/qgis-server.

TODO: Der folgende Befehl ist nicht mehr nötig. in den Betriebsumgebungen zurückbauen.
```
oc policy add-role-to-user system:image-puller system:serviceaccount:MY-NAMESPACE:default --rolebinding-name puller-MY-NAMESPACE -n gdi-test
```

## Create secret

In a separate folder, create a file `qgis-server-seeder-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/qgis-server-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: qgis-server-seeder-secret
  labels:
    app: qgis-server-seeder
stringData:
  pg_service.conf: |
    [sogis_pub]
    host=xy
    port=5432
    dbname=xy
    user=xy
    password=xy
    sslmode=require
```

## Create ConfigMap

In a separate folder, create a file `oereb-web-service-configmap.yaml`
containing a ConfigMap according to the following template.
(Replace HOSTNAME with the DB server host name or IP address.)
Then run `oc apply -f path/to/oereb-web-service-configmap.yaml -n my-namespace`.

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: oereb-web-service-configmap
  labels:
    app: oereb-web-service
data:
  dburl: jdbc:postgresql://HOSTNAME/oereb_v2?sslmode=require
```

## Apply template

```
oc process -f mapcache/mapcache.yaml --param-file=mapcache/mapcache_test.params | oc apply -f - -n my-namespace
```
