# Deploying Api Gateway in OpenShift

## Create and configure project

Create project
```
oc new-project my-namespace
```

Set secret for pulling images from image registry (optional)
```
oc create secret docker-registry sogis-pull-secret   --docker-username=dockeruser   --docker-password=password
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

In a separate folder, create a file `api-gateway-logitio-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/api-gateway-logitio-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: api-gateway-logitio-secret
  labels:
    app: api-gateway
stringData:
  logstash_host: xy
```

Another secret `api-gateway-cert` is created automatically when creating the service api-gateway (service serving certificate see https://docs.openshift.com/container-platform/4.10/security/certificates/service-serving-certificate.html). To create a service serving certificate you must add an annotation to the service 

```
metadata:
  annotations:
    service.alpha.openshift.io/serving-cert-secret-name: api-gateway-cert
```

## Create ConfigMap

ConfigMaps are defined and created via the ressources.yaml File.

## Apply template

```
oc process -f oereb-web-service/oereb-web-service.yaml --param-file=oereb-web-service/oereb-web-service_test.params | oc apply -f - -n my-namespace
```
