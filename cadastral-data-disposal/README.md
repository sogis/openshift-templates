# Install or update AV-Datenabgabe in OpenShift

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

Create a file secret.yaml for AWS with the following content; replace ACCESS_KEY and SECRET_KEY with the actual values:
```
apiVersion: v1
kind: Secret
metadata:
  name: cadastral-data-disposal-aws-secret
stringData:
  aws_access_key_id: ACCESS_KEY
  aws_secret_access_key: SECRET_KEY
```

Switch to the right OpenShift project (e.g. oc project agi-apps-test) and create the secret by running the following commands:
```
oc create -f secret.yaml
```

Deploy test environment (for the test environment, the default values of the template parameters are usually fine):

```
oc project agi-apps-test
oc process -f av-datenabgabe.yaml \
  --param-file=av-datenabgabe-test.env \
  | oc apply -f -
```

Deploy integration environment:

```
oc project agi-apps-integration
oc process -f av-datenabgabe.yaml \
  --param-file=av-datenabgabe-int.env \
  | oc apply -f -
```

Deploy production environment:

```
oc project agi-apps-production
oc process -f av-datenabgabe.yaml \
  --param-file=av-datenabgabe-prod.env \
  | oc apply -f -
```
