# Install or update MapCache in OpenShift

## Set up MapCache

A persistent volume claim for storing the tiles must exist already.


## Create a Docker image pull secret

This step is needed only if this is the first installation, or if any value of the secret needs to be changed.

Create a secret for pulling the Docker images, and link this secret to the default service account:

For test environment:

```
oc project agi-mapcache-test
oc create secret docker-registry sogis-pull-secret --docker-username=xx --docker-password=yy
oc secrets link default sogis-pull-secret --for=pull
```

For production environment:

Run the same commands as above, but connect to `agi-mapcache-production` before.


# Deploy MapCache

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
oc project agi-mapcache-test
oc process -f mapcache/mapcache_template.yaml \
  -p TAG=latest \
  -p IMPORT_POLICY_SCHEDULED=true \
  -p REPLICA_COUNT=1 \
  -p SERVICE_URL=https://geo-t.so.ch/api \
  -p SOURCE_URL=http://qgis-server.agi-mapcache-test.svc/ows/somap \
  -p TILES_PVC_NAME=gditest-mapcache-lowback \
  -p HOSTNAME=geo-wmts-t.so.ch \
  -p CPU_REQUEST=0 \
  -p CPU_LIMIT=0 \
  -p MEMORY_REQUEST=0 \
  -p MEMORY_LIMIT=0 \
  | oc apply -f -
```

Check the deployment:
```
https://geo-wmts-t.so.ch/mapcache/wmts/1.0.0/WMTSCapabilities.xml
```

Deploy production environment:
```
oc project agi-mapcache-production
oc process -f mapcache/mapcache_template.yaml \
  -p TAG=41 \
  -p IMPORT_POLICY_SCHEDULED=false \
  -p REPLICA_COUNT=2 \
  -p SERVICE_URL=https://geo.so.ch/api \
  -p SOURCE_URL=http://qgis-server.agi-mapcache-production.svc/ows/somap \
  -p TILES_PVC_NAME=gdi-mapcache-lowback \
  -p HOSTNAME=geo-wmts.so.ch \
  -p CPU_REQUEST=250m \
  -p CPU_LIMIT=1 \
  -p MEMORY_REQUEST=200Mi \
  -p MEMORY_LIMIT=600Mi \
  | oc apply -f -
```

Check the deployment:
```
https://geo-wmts.so.ch/mapcache/wmts/1.0.0/WMTSCapabilities.xml
```

## Set up a separate QGIS Server for seeding

Run the following commands to create a QGIS Server Deployment Configuration; the templates are based on those in https://github.com/sogis/pipelines/tree/master/api_webgisclient/qgis-server, and they are additionally modified so that they use the Image Registry of a different OpenShift project:

Deploy test environment:
```
oc project agi-mapcache-test
oc policy add-role-to-user system:image-puller system:serviceaccount:agi-mapcache-test:default --rolebinding-name puller-agi-mapcache-test -n gdi-test
oc process -f mapcache/qgis-server_resources.yaml \
  -p DB_SERVER=xy \
  -p DB_PUB=xy \
  -p USER_OGC_SERVER=xy \
  -p PW_OGC_SERVER=xy \
  | oc apply -f -
oc process -f mapcache/qgis-server_deploymentconfig.yaml \
  -p ENVIRONMENT=test \
  -p QGIS_SERVER_IMAGESTREAM_NAMESPACE=gdi-test \
  -p TAG=latest \
  -p REPLICAS=1 \
  -p CPU_REQUEST=0 \
  -p CPU_LIMIT=0 \
  -p MEMORY_REQUEST=0 \
  -p MEMORY_LIMIT=0 \
  | oc apply -f -
```

Deploy production environment:
```
oc project agi-mapcache-production
oc policy add-role-to-user system:image-puller system:serviceaccount:agi-mapcache-production:default --rolebinding-name puller-agi-mapcache-production -n gdi
oc process -f mapcache/qgis-server_resources.yaml \
  -p DB_SERVER=xy \
  -p DB_PUB=xy \
  -p USER_OGC_SERVER=xy \
  -p PW_OGC_SERVER=xy \
  | oc apply -f -
oc process -f mapcache/qgis-server_deploymentconfig.yaml \
  -p ENVIRONMENT=production \
  -p QGIS_SERVER_IMAGESTREAM_NAMESPACE=gdi \
  -p TAG=latest \
  -p REPLICAS=1 \
  -p CPU_REQUEST=1 \
  -p CPU_LIMIT=6 \
  -p MEMORY_REQUEST=2Gi \
  -p MEMORY_LIMIT=10Gi \
  | oc apply -f -
```

## Set up MapCache seeder Cron Job

Run the following commands to create an OpenShift Cron Job which regularly updates a part of the MapCache tiles:

In test environment:

(We don't run this cron job in test environment.)

In production environment:
```
oc project agi-mapcache-production
oc process -f mapcache/seeder-cronjob-template.yaml \
  -p NAMESPACE=agi-mapcache-production \
  -p PVC_NAME=gdi-mapcache-lowback \
  -p ZOOM_LEVELS=11,14 \
  -p SCHEDULE='00 03 * * *' \
  -p SOURCE_URL=http://qgis-server.agi-mapcache-production.svc/ows/somap \
  -p PGHOST=xy \
  -p PGDATABASE=pub \
  -p PGUSER=ogc_server \
  -p PGPASSWORD=xy \
  | oc apply -f -
```

## Run MapCache seeder Jobs that need to run on demand only

The *hintergrundkarte_ortho* tile set and the zoom levels 0 to 10 of the *ch.so.agi.hintergrundkarte_farbig* and the *ch.so.agi.hintergrundkarte_sw* tile set should be seeded on a local machine. Please refer to the instructions in the *seed* folder of the repository https://github.com/sogis/docker-mapcache.

For manual seeding of the zoom levels 11 to 14 of the *ch.so.agi.hintergrundkarte_farbig* and *ch.so.agi.hintergrundkarte_sw* tile sets, use the following commands:

In test environment:
```
oc project agi-mapcache-test
oc process -f mapcache/seeder-job-template.yaml \
  -p NAMESPACE=agi-mapcache-test \
  -p PVC_NAME=gditest-mapcache-lowback \
  -p VARIANT=farbig \
  -p ZOOM_LEVELS=11,14 \
  -p SOURCE_URL=http://qgis-server.agi-mapcache-test.svc/ows/somap \
  | oc create -f -
oc process -f mapcache/seeder-job-template.yaml \
  -p NAMESPACE=agi-mapcache-test \
  -p PVC_NAME=gditest-mapcache-lowback \
  -p VARIANT=sw \
  -p ZOOM_LEVELS=11,14 \
  -p SOURCE_URL=http://qgis-server.agi-mapcache-test.svc/ows/somap \
  | oc create -f -
```

In production environment:
```
oc project agi-mapcache-production
oc process -f mapcache/seeder-job-template.yaml \
  -p NAMESPACE=agi-mapcache-production \
  -p PVC_NAME=gdi-mapcache-lowback \
  -p VARIANT=farbig \
  -p ZOOM_LEVELS=11,14 \
  -p SOURCE_URL=http://qgis-server.agi-mapcache-production.svc/ows/somap \
  | oc create -f -
oc process -f mapcache/seeder-job-template.yaml \
  -p NAMESPACE=agi-mapcache-production \
  -p PVC_NAME=gdi-mapcache-lowback \
  -p VARIANT=sw \
  -p ZOOM_LEVELS=11,14 \
  -p SOURCE_URL=http://qgis-server.agi-mapcache-production.svc/ows/somap \
  | oc create -f -
```

(If any of these jobs already exists, you might need to delete it using the command `oc delete job JOB-NAME`.)
