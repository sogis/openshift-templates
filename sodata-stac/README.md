# Deploying sodata-stac in OpenShift

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

In a separate folder, create a file `sodata-stac-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/sodata-stac-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: sodata-stac-secret
  labels:
    app: sodata-stac
stringData:
  DBUSR: xy
  DBPWD: xy
```

## Create ConfigMap

In a separate folder, create a file `sodata-stac-configmap.yaml`
containing a ConfigMap according to the following template.
(Replace HOSTNAME with the DB server host name or IP address.)
Then run `oc apply -f path/to/sodata-stac-configmap.yaml -n my-namespace`.

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: sodata-stac-configmap
  labels:
    app: sodata-stac
data:
  DBURL: jdbc:postgresql://HOSTNAME/DBNAME?sslmode=require
```

## Apply template

```
oc process -f sodata-stac/sodata-stac.yaml --param-file=sodata-stac/sodata-stac_test.params | oc apply -f - -n my-namespace
```
