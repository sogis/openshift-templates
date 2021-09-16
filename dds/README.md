# Install or update the dds upload service in OpenShift

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
oc process -f dds/dds.yaml \
  -p ENV=test \
  -p TAG=latest \
  -p IMPORT_POLICY_SCHEDULED=true \
  -p CPU_LIMIT="0" \
  -p MEMORY_LIMIT="0" \
  -p CPU_REQUEST="0" \
  -p MEMORY_REQUEST="0" \
  | oc apply -f -
```

Deploy integration environment:

```
oc project agi-apps-integration
oc process -f dds/dds.yaml \
  -p ENV=int \
  -p TAG=X.X \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p CPU_LIMIT="750m" \
  -p MEMORY_LIMIT="600Mi" \
  -p CPU_REQUEST="60m" \
  -p MEMORY_REQUEST="300Mi" \
  | oc apply -f -
```

Deploy production environment:

```
oc project agi-apps-production
oc process -f dds/dds.yaml \
  -p ENV=prod \
  -p TAG=X.X \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p CPU_LIMIT="750m" \
  -p MEMORY_LIMIT="600Mi" \
  -p CPU_REQUEST="60m" \
  -p MEMORY_REQUEST="600Mi" \
  | oc apply -f -
```
