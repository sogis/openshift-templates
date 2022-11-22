# Deploying pgwatch2 in OpenShift

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

## Create secrets

In a separate folder, create a file e.g. `pgwatch2-grafanuser-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/pgwatch2-grafanauser-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: pgwatch2-grafanauser-secret
  labels:
    app: pgwatch2
stringData:
  PW2_GRAFANAUSER: xy
  PW2_GRAFANPASSWORD: xy
```

```
kind: Secret
apiVersion: v1
metadata:
  name: pgwatch2-webuser-secret
  labels:
    app: pgwatch2
stringData:
  PW2_WEBUSER: xy
  PW2_WEBPASSWORD: xy
```

```
kind: Secret
apiVersion: v1
metadata:
  name: pgwatch2-influx-secret
  labels:
    app: pgwatch2
stringData:
  PW2_IUSER: xy
  PW2_IPASSWORD: xy
```

```
kind: Secret
apiVersion: v1
metadata:
  name: pgwatch2-postgres-secret
  labels:
    app: pgwatch2
stringData:
  PW2_PGUSER: xy
  PW2_PGPASSWORD: xy
```

## Create ConfigMap

In a separate folder, create a file `pgwatch2-configmap.yaml`
containing a ConfigMap according to the following template.
(Replace HOSTNAME with the DB server host name or IP address.)
Then run `oc apply -f path/to/pgwatch2-configmap.yaml -n my-namespace`.

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: pgwatch2-configmap
  labels:
    app: pgwatch2
data:
  PW2_PGHOST: hostname
  PW2_PGDATABASE: dbname
  PW2_PGPORT: port
  PW2_IHOST: hostname
  PW2_IDATABASE: dbname
  PW2_IPORT: port
```

## Apply template

```
oc process -f pgwatch2/pgwatch2.yaml --param-file=pgwatch2/pgwatch2_test.params | oc apply -f - -n my-namespace
```
