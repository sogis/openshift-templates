# pgAdmin4

## First install in an Openshift Environment

All necassary components of the application are configured in the template pgadmin4.yaml.
Set DB_SERVER parameter to the desired DB Connection
Set env parameter to set environment
Set version parameter to set Image version
```
oc process -f pgadmin4.yaml \
  -p version=latest \
  -p CPU_LIMIT="800m" \
  -p MEMORY_LIMIT="800Mi" \
  -p CPU_REQUEST="20m" \
  -p MEMORY_REQUEST="400Mi" \
  | oc apply -f-
oc process -f pgadmin4.yaml \
  -p version=4.20 \
  -p CPU_LIMIT="800m" \
  -p MEMORY_LIMIT="800Mi" \
  -p CPU_REQUEST="20m" \
  -p MEMORY_REQUEST="800Mi" \
  | oc apply -f-
```

## Update of app configuration in Openshift Environment

Make changes to the configuration in the template heatdrill.yaml and run
```
oc process -f heatdrill.yaml \
  -p DB_SERVER=geodb-t.verw.rootso.org \
  -p DB_PW=password \
  -p env=test \
  -p version=latest \
  -p CPU_LIMIT="0" \
  -p MEMORY_LIMIT="0" \
  -p CPU_REQUEST="0" \
  -p MEMORY_REQUEST="0" \
  | oc apply -f-
oc process -f heatdrill.yaml \
  -p DB_SERVER=geodb-t.verw.rootso.org \
  -p DB_PW=password \
  -p env=test \
  -p version=latest \
  -p CPU_LIMIT="800m" \
  -p MEMORY_LIMIT="800Mi" \
  -p CPU_REQUEST="20m" \
  -p MEMORY_REQUEST="400Mi" \
  | oc apply -f-
oc process -f heatdrill.yaml \
  -p DB_SERVER=geodb-t.verw.rootso.org \
  -p DB_PW=password \
  -p env=test \
  -p version=latest \
  -p CPU_LIMIT="800m" \
  -p MEMORY_LIMIT="800Mi" \
  -p CPU_REQUEST="20m" \
  -p MEMORY_REQUEST="800Mi" \
  | oc apply -f-
```
