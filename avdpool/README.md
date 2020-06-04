# Install or update the avdpool import service in OpenShift

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
oc process -f avdpool/avdpool.yaml \
  -p ENVIRONMENT_SHORT=test \
  -p TAG=latest \
  -p IMPORT_POLICY_SCHEDULED=true \
  -p AWS_ACCESS_KEY=xy \
  -p AWS_SECRET_KEY=xy \
  -p EMAIL_SMTP_SENDER=xy \
  -p EMAIL_USER_SENDER='AV-Import Test <avimport-t@agi.so.ch>' \
  -p EMAIL_USER_RECIPIENT=xy \
  -p FTP_USER_INFOGRIPS=xy \
  -p FTP_PWD_INFOGRIPS=xy \
  -p DB_USER_EDIT=xy \
  -p DB_PWD_EDIT=xy \
  -p CPU_LIMIT="0" \
  -p MEMORY_LIMIT="0" \
  -p CPU_REQUEST="0" \
  -p MEMORY_REQUEST="0" \
  | oc apply -f -
```

Deploy integration environment:

```
oc project agi-apps-integration
oc process -f avdpool/avdpool.yaml \
  -p ENVIRONMENT_SHORT=int \
  -p TAG=1.0.58 \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p AWS_ACCESS_KEY=xy \
  -p AWS_SECRET_KEY=xy \
  -p EMAIL_SMTP_SENDER=xy \
  -p EMAIL_USER_SENDER='AV-Import Integration <avimport-i@agi.so.ch>' \
  -p EMAIL_USER_RECIPIENT=xy \
  -p FTP_USER_INFOGRIPS=xy \
  -p FTP_PWD_INFOGRIPS=xy \
  -p DB_USER_EDIT=xy \
  -p DB_PWD_EDIT=xy \
  -p CPU_LIMIT="1200m" \
  -p MEMORY_LIMIT="1000Mi" \
  -p CPU_REQUEST="100m" \
  -p MEMORY_REQUEST="500Mi" \
  | oc apply -f -
```

Deploy production environment:

```
oc project agi-apps-production
oc process -f avdpool/avdpool.yaml \
  -p ENVIRONMENT_SHORT=prod \
  -p TAG=1.0.58 \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p AWS_ACCESS_KEY=xy \
  -p AWS_SECRET_KEY=xy \
  -p EMAIL_SMTP_SENDER=xy \
  -p EMAIL_USER_SENDER='AV-Import <avimport@agi.so.ch>' \
  -p EMAIL_USER_RECIPIENT=xy \
  -p FTP_USER_INFOGRIPS=xy \
  -p FTP_PWD_INFOGRIPS=xy \
  -p DB_USER_EDIT=xy \
  -p DB_PWD_EDIT=xy \
  -p CPU_LIMIT="1200m" \
  -p MEMORY_LIMIT="1000Mi" \
  -p CPU_REQUEST="100m" \
  -p MEMORY_REQUEST="1000Mi" \
  | oc apply -f -
```
