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
  -p CPU_LIMIT="0" \
  -p MEMORY_LIMIT="0" \
  -p CPU_REQUEST="0" \
  -p MEMORY_REQUEST="0" \
  -p ENVIRONMENT_SHORT=test \
  | oc apply -f -
```

Deploy integration environment:

```
oc project agi-apps-integration
oc process -f standortkarte/standortkarte.yaml \
  -p TAG=2.0.22 \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p CPU_LIMIT="200m" \
  -p MEMORY_LIMIT="200Mi" \
  -p CPU_REQUEST="10m" \
  -p MEMORY_REQUEST="100Mi" \
  -p ENVIRONMENT_SHORT=int \
  | oc apply -f -
```

Deploy production environment:

```
oc project agi-apps-production
oc process -f standortkarte/standortkarte.yaml \
  -p TAG=2.0.22 \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p REPLICA_COUNT=2 \
  -p CPU_LIMIT="200m" \
  -p MEMORY_LIMIT="200Mi" \
  -p CPU_REQUEST="10m" \
  -p MEMORY_REQUEST="100Mi" \
  -p ENVIRONMENT_SHORT=prod \
  | oc apply -f -
```
