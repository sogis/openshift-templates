# Install or update the Standortkarte application in OpenShift

## Install or update the application

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
oc process -f standortkarte/standortkarte.yaml \
  -p TAG=latest \
  -p IMPORT_POLICY_SCHEDULED=true \
  | oc apply -f -
```

Deploy integration environment:

```
oc project agi-apps-integration
oc process -f standortkarte/standortkarte.yaml \
  -p TAG=1.0.4 \
  -p IMPORT_POLICY_SCHEDULED=false \
  | oc apply -f -
```

Deploy production environment:

```
oc project agi-apps-production
oc process -f standortkarte/standortkarte.yaml \
  -p TAG=1.0.4 \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p REPLICA_COUNT=2 \
  | oc apply -f -
```
