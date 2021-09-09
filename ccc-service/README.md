# ccc-service

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
