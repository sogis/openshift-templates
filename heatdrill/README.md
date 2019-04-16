# heatdrill

## First install in an Openshift Environment

All necassary components of the application are configured in the template heatdrill.yaml.
Set DB_SERVER parameter to the desired DB Connection
```
oc process -f heatdrill.yaml -p DB_SERVER=geodb-t.verw.rootso.org -p DB_PW=password | oc create -f-
```

## Update of app configuration in Openshift Environment

Make changes to the configuration in the template heatdrill.yaml and run
```
oc process -f heatdrill.yaml -p DB_SERVER=geodb-t.verw.rootso.org -p DB_PW=password | oc apply -f-
```
