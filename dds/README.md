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

Create the following three secret YAML files locally,
in a directory outside the checked out Git repository.
Then, in each environment (test, integration, production)

```
oc create -f FILENAME
```

Deploy test environment:

```
oc project agi-apps-test
oc process -f dds/dds.yaml \
  -p env=test \
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
  -p env=int \
  -p TAG=1.0.19 \
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
  -p env=prod \
  -p TAG=1.0.19 \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p CPU_LIMIT="750m" \
  -p MEMORY_LIMIT="600Mi" \
  -p CPU_REQUEST="60m" \
  -p MEMORY_REQUEST="600Mi" \
  | oc apply -f -
```
