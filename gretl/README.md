# Deploying the GRETL pod template in OpenShift

Note: This template only creates one or more ConfigMaps
that serve as pod templates for running GRETL jobs,
and the required image streams.
Jenkins must currently still be deployed manually.

## Create and configure project

Create project
```
oc new-project my-namespace
```

Set secret for pulling images from image registry (optional)
```
oc create secret docker-registry dockerhub-pull-secret --docker-username=xy --docker-password=xy -n my-namespace
oc secrets link default dockerhub-pull-secret --for=pull -n my-namespace
oc secrets link jenkins dockerhub-pull-secret --for=pull -n my-namespace
```

Grant permissions for deploying the app
from a Jenkins instance running in a different namespace (optional);
replace JENKINS-NAMESPACE with the name of the namespace
where Jenkins is deployed
```
oc policy add-role-to-user edit system:serviceaccount:JENKINS-NAMESPACE:jenkins -n my-namespace
```

Grant permissions on project (optional)
```
oc policy add-role-to-user admin ... -n my-namespace
oc policy add-role-to-user view ... -n my-namespace
```

## Create secret

In a separate folder, create a file `gretl-secrets.yaml`
containing secrets according to the template
https://github.com/sogis/gretl/blob/master/openshift/templates/gretl-secrets-example.yaml.
Then run `oc apply -f path/to/gretl-secrets.yaml -n my-namespace`.

## Create ConfigMap

In a separate folder, create a file `gretl-resources.yaml`
containing a ConfigMap according to the template
https://github.com/sogis/gretl/blob/master/openshift/templates/gretl-resources-example.yaml.
Then run `oc apply -f path/to/gretl-resources.yaml -n my-namespace`.

## Create service account and role binding

In a separate folder, create a file `jenkins-sa.yaml`
containing the following definition of a service account and a role binding:
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  labels:
    app: gretl-platform
  annotations:
    serviceaccounts.openshift.io/oauth-redirectreference.jenkins: '{"kind":"OAuthRedirectReference","apiVersion":"v1","reference":{"kind":"Route","name":"jenkins"}}'
---
apiVersion: authorization.openshift.io/v1
kind: RoleBinding
metadata:
  name: jenkins_edit
  labels:
    app: gretl-platform
roleRef:
  name: edit
subjects:
- kind: ServiceAccount
  name: jenkins
```
Then run `oc apply -f path/to/jenkins-sa.yaml -n my-namespace`.

## Create Persistent Volume Claim

In a separate folder, create a file `jenkins-pvc.yaml`
containing the definition of a Persistent Volume Claim
according to the following template:
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins
labels:
  app: gretl-platform
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```
Then run `oc apply -f path/to/jenkins-pvc.yaml -n my-namespace`.

## Apply template

(For local usage a particular `gretl_development.params` file is available.)

```
oc process -f gretl/gretl.yaml --param-file=gretl/gretl_development.params | oc apply -f - -n my-namespace
```