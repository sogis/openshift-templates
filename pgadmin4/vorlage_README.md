# Deploying pgadmin4 in OpenShift

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

In a separate folder, create a file `pgadmin4-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/pgadmin4-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: pgadmin4-secret
  labels:
    app: pgadmin4
stringData:
  PGADMIN_DEFAULT_EMAIL: xy
  PGADMIN_DEFAULT_PASSWORD: xy
```

## Apply template

```
oc process -f pgadmin4/pgadmin4.yaml --param-file=pgadmin4/pgadmin4_test.params | oc apply -f - -n my-namespace
```
