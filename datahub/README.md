# Deploying Data Hub in OpenShift

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

## Create DB secret

In a separate folder, create a file `datahub-db-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/datahub-db-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: datahub-db-secret
  labels:
    app: datahub
stringData:
  DBURL: jdbc:postgresql://hostname/dbname
  DBUSR: xy
  DBPWD: xy
```

## Create mail server secret

In a separate folder, create a file `datahub-mail-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/datahub-mail-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: datahub-mail-secret
  labels:
    app: datahub
stringData:
  MAIL_HOST: xy
  MAIL_PORT: 'nnnn'
```

## Create dashboard secret

In a separate folder, create a file `datahub-dashboard-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/datahub-dashboard-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: datahub-dashboard-secret
  labels:
    app: datahub
stringData:
  JOBRUNR_DASHBOARD_USER: xy
  JOBRUNR_DASHBOARD_PWD: xy
```

## Apply template

```
oc process -f datahub/datahub.yaml --param-file=datahub/datahub_test.params | oc apply -f - -n my-namespace
```
