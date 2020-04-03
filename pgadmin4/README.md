# pgAdmin4

## First install and update of app in an Openshift Environment

All necassary components of the application are configured in the template pgadmin4.yaml.
Set env parameter to set environment
Set version parameter to set Image version
```
oc process -f pgadmin4.yaml \
  -p version=latest \
  -p scheduled=true \
  -p env="-integration" \ 
  -p CPU_LIMIT="800m" \
  -p MEMORY_LIMIT="800Mi" \
  -p CPU_REQUEST="20m" \
  -p MEMORY_REQUEST="400Mi" \
  | oc apply -f-
oc process -f pgadmin4.yaml \
  -p version=4 \
  -p CPU_LIMIT="800m" \
  -p MEMORY_LIMIT="800Mi" \
  -p CPU_REQUEST="20m" \
  -p MEMORY_REQUEST="800Mi" \
  | oc apply -f-
```
