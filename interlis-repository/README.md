# interlis-repository

## First install in an Openshift Environment

All necessary components of the application are configured in the template interlis-repository.yaml
```
oc process -f interlis-repository.yaml \
  -p APPNAME=interlis_repository \
  -p IMAGENAME=sogis/interlis-repository \
  -p TAG=latest \
  -p IMPORT_POLICY_SCHEDULED=true \
  -p REPLICA_COUNT="1" \
  -p CPU_LIMIT="0" \
  -p MEMORY_LIMIT="0" \
  -p CPU_REQUEST="0" \
  -p MEMORY_REQUEST="0" \
  | oc apply -n agi-apps-test -f-
oc process -f interlis-repository.yaml \
  -p APPNAME=interlis_repository \
  -p IMAGENAME=sogis/interlis-repository \
  -p TAG=latest \
  -p IMPORT_POLICY_SCHEDULED=true \
  -p REPLICA_COUNT="1" \
  -p CPU_LIMIT="50m" \
  -p MEMORY_LIMIT="100Mi" \
  -p CPU_REQUEST="10m" \
  -p MEMORY_REQUEST="50Mi" \
  | oc apply -n agi-apps-integration -f-
oc process -f interlis-repository.yaml \
  -p APPNAME=interlis_repository \
  -p IMAGENAME=sogis/interlis-repository \
  -p TAG=latest \
  -p IMPORT_POLICY_SCHEDULED=true \
  -p REPLICA_COUNT="2" \
  -p CPU_LIMIT="50m" \
  -p MEMORY_LIMIT="100Mi" \
  -p CPU_REQUEST="10m" \
  -p MEMORY_REQUEST="100Mi" \
  | oc apply -n agi-apps-production -f-
```

## Update of app configuration in Openshift Environment

Make changes to the configuration in the template interlis-repository.yaml and run
Set environment with parameter env, docker image version with parameter version and scheduled or not with parameter scheduled
```
oc process -f interlis-repository.yaml \
  -p env=test \
  -p version=latest \
  -p scheduled=true \
  -p CPU_LIMIT="0" \
  -p MEMORY_LIMIT="0" \
  -p CPU_REQUEST="0" \
  -p MEMORY_REQUEST="0" \
  | oc apply -f-
oc process -f interlis-repository.yaml \
  -p env=integration \
  -p version=latest \
  -p scheduled=true \
  -p CPU_LIMIT="50m" \
  -p MEMORY_LIMIT="100Mi" \
  -p CPU_REQUEST="10m" \
  -p MEMORY_REQUEST="50Mi" \
  | oc apply -f-
oc process -f interlis-repository.yaml \
  -p env=production \
  -p version=latest \
  -p scheduled=true \
  -p CPU_LIMIT="50m" \
  -p MEMORY_LIMIT="100Mi" \
  -p CPU_REQUEST="10m" \
  -p MEMORY_REQUEST="100Mi" \
  | oc apply -f-
```
