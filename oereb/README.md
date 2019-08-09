# Install or update the OEREB application (OEREB WMS and OEREB Web Service) in OpenShift

## Create a secret

This step is needed only if this is the first installation, or if any value of the secret needs to be changed.

Create a file *oereb-wms-secret.yaml* with the following content; replace `DBHOST`, `DBNAME`, `DBUSER` and `DBPASSWORD` with the actual values:
```
apiVersion: v1
kind: Secret
metadata:
  name: oereb-wms-secret
stringData:
  pg_service.conf: |-
    [oereb]
    host=DBHOST
    dbname=DBNAME
    user=DBUSER
    password=DBPASSWORD
```

Switch to the right OpenShift project (e.g. `oc project agi-oereb-test`) and create the secret by running the following command:
```
oc create -f oereb-wms-secret.yaml
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
```

Deploy integration environment:

```
oc project agi-oereb-integration
oc process -f oereb/oereb-wms.yaml \
  -p TAG=f01f5ad \
  | oc apply -f -
```

Deploy production environment:

```
oc project agi-oereb-production
oc process -f oereb/oereb-wms.yaml \
  -p TAG=f01f5ad \
  | oc apply -f -
```
