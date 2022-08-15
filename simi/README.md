# Deploying Simi in OpenShift

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

In a separate folder, create a file `simi-db-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/simi-db-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: simi-db-secret
  labels:
    app: simi
type: Opaque
stringData:
  CUBA_DATASOURCE_USERNAME: xy
  CUBA_DATASOURCE_PASSWORD: xy
  CUBA_DATASOURCE_JDBCURL: xy
```

In a separate folder, create a file `simi-ldap-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/simi-ldap-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: simi-ldap-secret
  labels:
    app: simi
type: Opaque
stringData:
  CUBA_WEB_LDAP_URLS: xy
  CUBA_WEB_LDAP_BASE: xy
  CUBA_WEB_LDAP_USER: xy
  CUBA_WEB_LDAP_PASSWORD: xy
  CUBA_WEB_LDAP_USERLOGINFIELD: xy
```

## Apply template

```
oc process -f simi/simi.yaml --param-file=simi/simi_test.params | oc apply -f - -n my-namespace
```
