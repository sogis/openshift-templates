# pdf4oereb-service

## First install in an Openshift Environment

All necessary components of the application are configured in the template pdf4oereb.yaml
Set environment with parameter env, docker image version with parameter version and scheduled or not with parameter scheduled
```
oc process -p env=test -p version=latest -p scheduled=true -f pdf4oereb.yaml  | oc apply -f-
```

## Update of app configuration in Openshift Environment

Make changes to the configuration in the template pdf4oereb.yaml and run
Set environment with parameter env, docker image version with parameter version and scheduled or not with parameter scheduled
```
oc process -p env=test -p version=latest -p scheduled=true -f pdf4oereb.yaml  | oc apply -f-
```
