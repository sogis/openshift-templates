# Install or update the cadastre-web-service application in OpenShift

## Create a secret

This step is needed only if this is the first installation, or if any value of the secret needs to be changed.

Create a file *cadastre.yaml* for the cadastre wms with the following content; replace `DBHOST`, `DBNAME`, `DBUSER` and `DBPASSWORD` with the actual values:
```
apiVersion: v1
kind: Secret
metadata:
  name: cadastre-wms-secret
  labels:
    app: cadastre-wms
stringData:
  pg_service.conf: |-
    [oereb]
    host=DBHOST
    dbname=DBNAME
    user=DBUSER
    password=DBPASSWORD
    options=-c search_path=public,live
```

Switch to the right OpenShift project (e.g. `oc project agi-test`) and create the secret(s) by running the following commands:
```
oc create -f cadastre-web-service.yaml
```

Run this command in the *agi-test* OpenShift projects.


## Install or update the cadastre application

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
oc project agi-apps-test
oc process -f cadastre/cadastre.yaml \
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
