# Deploying Ilivalidator Web Service in OpenShift

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

In a separate folder, create a file `ilivalidator-web-service-aws-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/ilivalidator-web-service-aws-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: ilivalidator-web-service-aws-secret
  labels:
    app: ilivalidator-web-service
data:
  AWS_ACCESS_KEY_ID: xy
  AWS_SECRET_ACCESS_KEY: xy
```

## Apply template

```
oc process -f ilivalidator-web-service/ilivalidator-web-service.yaml --param-file=ilivalidator-web-service/ilivalidator-web-service_test.params | oc apply -f - -n my-namespace
```
