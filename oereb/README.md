# Install or update the OEREB application (OEREB WMS and OEREB Web Service) in OpenShift

## Create a secret

This step is needed only if this is the first installation, or if any value of the secret needs to be changed.

Create a file *oereb-wms-secret.yaml* for the oereb wms with the following content; replace `DBHOST`, `DBNAME`, `DBUSER` and `DBPASSWORD` with the actual values:
```
apiVersion: v1
kind: Secret
metadata:
  name: oereb-wms-secret
  labels:
    app: oereb-wms
stringData:
  pg_service.conf: |-
    [oereb]
    host=DBHOST
    dbname=DBNAME
    user=DBUSER
    password=DBPASSWORD
    options=-c search_path=public,live
```
Create a file *oereb-web-service-secret.yaml* for the oereb web service with the following content; replace `DBUSER` and `DBPASSWORD` with the actual values:
```
apiVersion: v1
kind: Secret
metadata:
  name: oereb-web-service-secret
stringData:
  username: DBUSER
  password: DBPASSWORD
```

Switch to the right OpenShift project (e.g. `oc project agi-oereb-test`) and create the secret(s) by running the following commands:
```
oc create -f oereb-wms-secret.yaml
oc create -f oereb-web-service.yaml
```

Run this command in the *agi-oereb-test*, *agi-oereb-integration* and *agi-oereb-production* OpenShift projects.


## Install or update the OEREB application

Checkout the openshift-templates repository:

```
git clone https://github.com/sogis/openshift-templates.git
cd openshift-templates
```

Or, if already checked out, update the OpenShift templates repository:

```
cd openshift-templates
git pull
```


Deploy test environment:

```
oc project agi-oereb-test
oc process -f oereb/oereb-wms.yaml \
  -p TAG=latest \
  -p IMPORT_POLICY_SCHEDULED=true \
  | oc apply -f -
oc process -f oereb/oereb-web-service.yaml \
  -p version=latest \
  -p env=test \
  -p dbenv=geodb-t \
  -p dbschema=live \
  -p CPU_LIMIT="0" \
  -p MEMORY_LIMIT="0" \
  -p CPU_REQUEST="0" \
  -p MEMORY_REQUEST="0" \
  | oc apply -f -
```

Deploy integration environment:

```
oc project agi-oereb-integration
oc process -f oereb/oereb-wms.yaml \
  -p TAG=21 \
  -p IMPORT_POLICY_SCHEDULED=false \
  | oc apply -f -
oc process -f oereb/oereb-web-service.yaml \
  -p version=66 \
  -p env=integration \
  -p dbenv=geodb-i \
  -p dbschema=live \
  -p CPU_LIMIT="750m" \
  -p MEMORY_LIMIT="1400Mi" \
  -p CPU_REQUEST="100m" \
  -p MEMORY_REQUEST="700Mi" \
  | oc apply -f -
```

Deploy production environment:

```
oc project agi-oereb-production
oc process -f oereb/oereb-wms.yaml \
  -p TAG=a1f4432 \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p REPLICA_COUNT=2 \
  | oc apply -f -
oc process -f oereb/oereb-web-service.yaml \
  -p version=66 \
  -p env=production \
  -p dbenv=geodb
  -p dbschema=live \
  -p CPU_LIMIT="1250m" \
  -p MEMORY_LIMIT="1400Mi" \
  -p CPU_REQUEST="100m" \
  -p MEMORY_REQUEST="1400Mi" \
  | oc apply -f -
```
