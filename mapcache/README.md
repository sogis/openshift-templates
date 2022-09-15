# Deploying MapCache in OpenShift

## Notes on the MapCache seeder cron job

In addition to the MapCache service,
this template creates a MapCache seeder cron job
which updates a part of the MapCache tiles in regular intervals.

The cron job can be started manually as well.
Run the following command
for manual seeding of the zoom levels 11 to 14
of the `ch.so.agi.hintergrundkarte_farbig`
and `ch.so.agi.hintergrundkarte_sw` tile sets
of the most recently imported municipalities:

```
oc delete job mapcache-seeder-manual ; oc create job mapcache-seeder-manual --from=cronjob/mapcache-seeder -n my-namespace
```

TODO: Describe how to seed the whole extent of the tile sets (seeder-job-template).

The `hintergrundkarte_ortho` tile set and the zoom levels 0 to 10
of the `ch.so.agi.hintergrundkarte_farbig` and the `ch.so.agi.hintergrundkarte_sw` tile set
should be seeded on a local machine.
Please refer to the instructions in the seed folder of the
https://github.com/sogis/docker-mapcache Git repository.

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

## Create Persistent Volume Claim

In a separate folder, create a file `mapcache-pvc.yaml`
containing the definition of a Persistent Volume Claim
according to the following template.
Then run `oc apply -f path/to/mapcache-pvc.yaml -n my-namespace`.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mapcache
labels:
  app: mapcache
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 2Gi
```

## Create secret

In a separate folder, create a file `mapcache-seeder-db-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/mapcache-seeder-db-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: mapcache-seeder-db-secret
  labels:
    app: mapcache
stringData:
  pg_service.conf: |-
    [pub]
    host=xy
    port=5432
    dbname=xy
    user=xy
    password=xy
    sslmode=require
```

## Apply template

```
oc process -f mapcache/mapcache.yaml --param-file=mapcache/mapcache_development.params | oc apply -f - -n my-namespace
```


# Deploying QGIS Server (for seeding WMTS tiles) in OpenShift

## Enable running image with any UID

Enable QGIS Server image to be run wit any UID.
Note that the second command must be run as an administrator.
```
oc create sa qgis-server -n my-namespace
oc adm policy add-scc-to-user anyuid -z qgis-server -n my-namespace
```

## Create Persistent Volume Claims

In a separate folder, create a file `qgis-server-pvc.yaml`
containing the definition of a Persistent Volume Claim
according to the following template.
Then run `oc apply -f path/to/qgis-server-pvc.yaml -n my-namespace`.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: qgis-server-resources
labels:
  app: qgis-server
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: qgis-server-geodata
labels:
  app: qgis-server
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 2Gi
```


## Create secret

In a separate folder, create a file `qgis-server-db-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/qgis-server-db-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: qgis-server-db-secret
  labels:
    app: qgis-server
stringData:
  pg_service.conf: |-
    [sogis_pub]
    host=xy
    port=5432
    dbname=xy
    user=xy
    password=xy
    sslmode=require
```

## Apply template

```
oc process -f mapcache/qgis-server.yaml --param-file=mapcache/qgis-server_development.params | oc apply -f - -n my-namespace
```

## Set secret for pulling images from image registry on _qgis-server_ Service Account as well (optional)

```
oc secrets link qgis-server dockerhub-pull-secret --for=pull -n my-namespace
```
