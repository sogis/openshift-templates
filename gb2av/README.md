# Install or update the gb2av import service in OpenShift

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
Replace the `xy` placeholders with the appropriate values.
Then, in each environment (test, integration, production)
create the secrets by running

```
oc create -f FILENAME
```

aws-secret-gb2av.yaml:

```
apiVersion: v1
kind: Secret
metadata:
  name: aws-secret-gb2av
  labels:
    app: gb2av
type: Opaque
stringData:
  awsAccessKey: xy
  awsSecretKey: xy
```

infogrips-secret.yaml:

```
apiVersion: v1
kind: Secret
metadata:
  name: infogrips-secret
  labels:
    app: gb2av
type: Opaque
stringData:
  ftpUserInfogrips: xy
  ftpPwdInfogrips: xy
```

db-secret-gretl.yaml

```
apiVersion: v1
kind: Secret
metadata:
  name: db-secret-gretl
  labels:
    app: gb2av
type: Opaque
stringData:
  dbUser: xy
  dbPwd: xy
```

Deploy test environment:

```
oc project agi-apps-test
oc process -f gb2av/gb2av.yaml \
  -p ENVIRONMENT_SHORT=test \
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
oc process -f gb2av/gb2av.yaml \
  -p ENVIRONMENT_SHORT=int \
  -p TAG=1.0.16 \
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
oc process -f gb2av/gb2av.yaml \
  -p ENVIRONMENT_SHORT=prod \
  -p TAG=1.0.16 \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p CPU_LIMIT="750m" \
  -p MEMORY_LIMIT="600Mi" \
  -p CPU_REQUEST="60m" \
  -p MEMORY_REQUEST="750Mi" \
  | oc apply -f -
```
