# ccc-service

## Create a Docker image pull secret

This step is needed only if this is the first installation, or if any value of the secret needs to be changed.

Create a secret for pulling the Docker images, and link this secret to the default service account:
```
oc create secret docker-registry sogis-pull-secret --docker-username=xx --docker-password=yy
oc secrets link default sogis-pull-secret --for=pull
```

Run these commands in the test, integration and production OpenShift projects.


## First install in an Openshift Environment

Deploy test environment (for the test environment, the default values of the template parameters are usually fine):
```
oc project agi-ccc-service-test
oc process -f ccc-service.yaml \
  --param-file=parameters_test.env  \
  | oc apply -f-
```
Deploy integration environment:
```
oc project agi-ccc-service-integration
oc process -f ccc-service.yaml \
  --param-file=parameters_integration.env  \
  | oc apply -f-
```
Deploy production environment:
```
oc project agi-ccc-service-production
oc process -f ccc-service.yaml \
  --param-file=parameters_production.env  \
  | oc apply -f-
```
