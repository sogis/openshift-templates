# Indexupdater

## First install in an Openshift Environment

All necessary components of the application are configured in the template indexupdater.yaml
Set environment and desired version of the image
```
oc process -p env=test -p version=latest -f indexupdater.yaml  | oc apply -f-
```

## Update of app configuration in Openshift Environment

Make changes to the configuration in the template indexupdater.yaml and run
Set environment and desired version of the image
```
oc process -p env=test -p version=latest -f indexupdater.yaml  | oc apply -f-
```
