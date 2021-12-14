# avgbs2mtab-web-service

## First install in an Openshift Environment

All necessary components of the application are configured in the template avgbs2mtab-web-service.yaml
Set environment with parameter env and docker image version with parameter version
```
oc process -p env=test -p version=latest -p CPU_LIMIT="0" -p MEMORY_LIMIT="0" -p CPU_REQUEST="0" -p MEMORY_REQUEST="0" -f avgbs2mtab-web-service.yaml  | oc apply -f-
oc process -p env=integration -p version=1.1.8 -p CPU_LIMIT="800m" -p MEMORY_LIMIT="1000Mi" -p CPU_REQUEST="40m" -p MEMORY_REQUEST="500Mi" -f avgbs2mtab-web-service.yaml  | oc apply -f-
oc process -p env=production -p version=1.1.8 -p CPU_LIMIT="800m" -p MEMORY_LIMIT="1000Mi" -p CPU_REQUEST="40m" -p MEMORY_REQUEST="1000Mi" -f avgbs2mtab-web-service.yaml  | oc apply -f-
```

## Update of app configuration in Openshift Environment

Make changes to the configuration in the template avgbs2mtab-web-service.yaml and run
Set environment with parameter env and docker image version with parameter version
```
oc process -p env=test -p version=latest -p CPU_LIMIT="0" -p MEMORY_LIMIT="0" -p CPU_REQUEST="0" -p MEMORY_REQUEST="0" -f avgbs2mtab-web-service.yaml  | oc apply -f-
oc process -p env=integration -p version=1.1.8 -p CPU_LIMIT="800m" -p MEMORY_LIMIT="1000Mi" -p CPU_REQUEST="40m" -p MEMORY_REQUEST="500Mi" -f avgbs2mtab-web-service.yaml  | oc apply -f-
oc process -p env=production -p version=1.1.8 -p CPU_LIMIT="800m" -p MEMORY_LIMIT="1000Mi" -p CPU_REQUEST="40m" -p MEMORY_REQUEST="1000Mi" -f avgbs2mtab-web-service.yaml  | oc apply -f-
```
