# Deploying Simi Schemareader in OpenShift

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

In a separate folder, create a file `simi-schemareader-db-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/simi-schemareader-db-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: simi-schemareader-db-secret
  labels:
    app: simi-schemareader
type: Opaque
stringData:
  SPRING_APPLICATION_JSON: '{"dbs":[{"key":"edit","url":"jdbc:postgresql://localhost:5432/dbname","user":"dbuser","pass":"password"},{"key":"pub","url":"jdbc:postgresql://localhost:5432/dbname,"user":"dbuser","pass":"password"},{"key":"oereb","url":"jdbc:postgresql://localhost:5432/dbname","user":"dbuser","pass":"password"},{"key":"sogis","url":"jdbc:postgresql://localhost:5432/dbname","user":"dbuser","pass": "password"}]}'
```

## Apply template

```
oc process -f simi-schemareader/simi-schemareader.yaml --param-file=simi-schemareader/simi-schemareader_test.params | oc apply -f - -n my-namespace
```
