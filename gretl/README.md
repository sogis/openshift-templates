# Deploying the GRETL pod template in OpenShift

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
(Please note that the last command can be run successfully
only after the _jenkins_ service account has been created.
See a little further down in this document.)

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
containing secrets according to the following template.
Then run `oc apply -f path/to/gretl-secrets.yaml -n my-namespace`.

```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: gretl-secrets
  labels:
    app: gretl-platform
stringData:
  gradle.properties: |-
    dbUserEdit=myusername1
    dbPwdEdit=mypassword1
    dbUserPub=myusername2
    dbPwdPub=mypassword2
```

## Create ConfigMap

In a separate folder, create a file `gretl-resources.yaml`
containing a ConfigMap according to the following template.
Then run `oc apply -f path/to/gretl-resources.yaml -n my-namespace`.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: gretl-resources
  labels:
    app: gretl-platform
data:
  ORG_GRADLE_PROJECT_dbUriEdit: jdbc:postgresql://localhost/edit?sslmode=require&ApplicationName=GRETL
  ORG_GRADLE_PROJECT_dbUriPub: jdbc:postgresql://localhost/pub?sslmode=require&ApplicationName=GRETL
  ORG_GRADLE_PROJECT_ili2dbModeldir: '%ILI_FROM_DB;%XTF_DIR;https://geo.so.ch/models/;%JAR_DIR'
  ORG_GRADLE_PROJECT_ilivalidatorModeldir: '%ITF_DIR;https://geo.so.ch/models/;%JAR_DIR'
  ORG_GRADLE_PROJECT_geoservicesHostName: geo-t.so.ch
  ORG_GRADLE_PROJECT_gretlEnvironment: test
```

## Create service account and role binding

In a separate folder, create a file `jenkins-sa.yaml`
containing the following definition of a service account and a role binding.
Then run `oc apply -f path/to/jenkins-sa.yaml -n my-namespace`.

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

Now link the _dockerhub-pull-secret_ to the _jenkins_ service account as well:
```
oc secrets link jenkins dockerhub-pull-secret --for=pull -n my-namespace
```

## Create Persistent Volume Claim

In a separate folder, create a file `jenkins-pvc.yaml`
containing the definition of a Persistent Volume Claim
according to the following template.
Then run `oc apply -f path/to/jenkins-pvc.yaml -n my-namespace`.

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

## Create secret containing the configuration for authentication with Active Directory (optional)

**Note**: This secret is only needed
if you want to use Active Directory for authentication.

In a separate folder, create a file `gretl-jenkins-configuration-as-code-authentication.yaml`
containing a ConfigMap according to the following template.
Then run `oc apply -f path/to/gretl-jenkins-configuration-as-code-authentication.yaml -n my-namespace`.

```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: gretl-jenkins-configuration-as-code-authentication
  labels:
    app: gretl-platform
stringData:
  configuration-as-code-authentication.yaml: |
    jenkins:
      securityRealm:
        activeDirectory:
          customDomain: true
          domains:
          - bindName: "dummy@mydomain.org"
            bindPassword: "secret"
            name: "mydomain.org"
            servers: "mydomain.org:3269"
            tlsConfiguration: JDK_TRUSTSTORE
          groupLookupStrategy: AUTO
          removeIrrelevantGroups: false
          requireTLS: true
          startTls: true
      authorizationStrategy:
        projectMatrix:
          permissions:
          - "USER:Overall/Administer:myusername"
```

## Create secret for checking out a private Git repository sogis/schema-jobs

For enabling the GRETL jobs to check out the sogis/schema-jobs Git repository,
which is a private repository,
in a separate folder create a file `github-access-token-schema-jobs.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/github-access-token-schema-jobs.yaml -n my-namespace`.

```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: github-access-token-schema-jobs
  labels:
    app: gretl-platform
    credential.sync.jenkins.openshift.io: "true"
stringData:
  username: myMachineUsername
  password: myAccessToken
```

## Create ConfigMap containing an additional CA certificate

Place your additional CA certificate in a separate folder.
Then create a ConfigMap from it:
```
oc create --dry-run=client configmap gretl-jenkins-ca-certificates --from-file=ca-bundle.crt=mycertificatefilename.crt -o yaml > gretl-jenkins-ca-certificates.yaml
```
Then run
```
oc apply -f gretl-jenkins-ca-certificates.yaml -n my-namespace
oc label configmap gretl-jenkins-ca-certificates app=gretl-platform -n my-namespace
```

## Create secret containing an additional SSH private key

Place your additional SSH private key in a separate folder.
Then create a secret from it:
```
oc create --dry-run=client secret generic gretl-privatekeys --from-file=id_rsa=myprivatekeyfilename -o yaml > gretl-privatekeys.yaml
```
Then run
```
oc apply -f gretl-privatekeys.yaml -n my-namespace
oc label secret gretl-privatekeys app=gretl-platform -n my-namespace
```

## Apply template

(For local usage a particular `gretl_development.params` file is available.)

```
oc process -f gretl/gretl.yaml --param-file=gretl/gretl_development.params | oc apply -f - -n my-namespace
```
