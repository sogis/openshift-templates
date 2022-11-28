# Deploying ldap2pg cron job in OpenShift

## Create and configure project

Create project
```
oc new-project my-namespace
```

Set secret for pulling images from image registry (optional)
```
oc create secret docker-registry dockerhub-pull-secret --docker-username=xy --docker-password=xy -n my-namespace
oc secrets link default dockerhub-pull-secret --for=pull -n my-namespace
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

## Create DB secret

In a separate folder, create a file `ldap2pg-db-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/ldap2pg-db-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: ldap2pg-db-secret
  labels:
    app: ldap2pg
stringData:
  pg_service.conf: |-
    [ldap2pg]
    host=xy
    port=5432
    dbname=xy
    user=xy
    password=xy
    sslmode=require
```

## Create LDAP secret

In a separate folder, create a file `ldap2pg-ldap-secret.yaml`
containing a secret according to the following template.
Then run `oc apply -f path/to/ldap2pg-ldap-secret.yaml -n my-namespace`.

```
kind: Secret
apiVersion: v1
metadata:
  name: ldap2pg-ldap-secret
  labels:
    app: ldap2pg
stringData:
  LDAPURI: xy
  LDAPBINDDN: xy
  LDAPPASSWORD: xy
```

## Create ConfigMap containing the ldap2pg configuration

In a separate folder, create a file `ldap2pg-configmap.yaml`
containing a ConfigMap according to the following template.
Then run `oc apply -f path/to/ldap2pg-configmap.yaml -n my-namespace`.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: ldap2pg-configmap
  labels:
    app: ldap2pg
data:
  ldap2pg.yml: |
    version: 5
    postgres:
      [...]
    sync_map:
      [...]
```

## Create ConfigMap containing an individual CA certificate

Place your CA certificate in a separate folder.
Then convert it and create a ConfigMap from it:
```
openssl x509 -inform der -in originalcertificatefilename.crt -out mycertificatefilename.crt
oc create --dry-run=client configmap ldap2pg-ca-certificates --from-file=ca-certificates.crt=mycertificatefilename.crt -o yaml > ldap2pg-ca-certificates.yaml
```
Then run
```
oc apply -f ldap2pg-ca-certificates.yaml -n my-namespace
oc label configmap ldap2pg-ca-certificates app=ldap2pg -n my-namespace
```

## Apply template

```
oc process -f ldap2pg/ldap2pg.yaml --param-file=ldap2pg/ldap2pg_test.params | oc apply -f - -n my-namespace
```

# Starting the job manually

If you want to manually trigger a run of the cron job,
run the following commands:

```
oc delete job ldap2pg-manual -n my-namespace ; oc create job ldap2pg-manual --from=cronjob/ldap2pg -n my-namespace
```
