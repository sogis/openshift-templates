# Install or update the cadastre-web-service application in OpenShift

## Create a secret

This step is needed only if this is the first installation, or if any value of the secret needs to be changed.

Create a file *cadastre-web-service-secret.yaml* for the cadastre web service with the following content; replace `DBUSER` and `DBPASSWORD` with the actual values:
```
apiVersion: v1
kind: Secret
metadata:
  name: cadastre-web-service-secret
stringData:
  username: DBUSER
  password: DBPASSWORD
```

Switch to the right OpenShift project (e.g. `oc project agi-apps-test`) and create the secret(s) by running the following commands:
```
oc create -f cadastre-web-service-secret.yaml
```

Run this command in the *agi-apps-test*, *agi-apps-integration* and *agi-apps-production* OpenShift projects.


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
oc process -f cadastre/cadastre-web-service.yaml \
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
