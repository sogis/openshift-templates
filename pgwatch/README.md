# Install or Update pgwatch2 in Openshift
Checkout this repo 
```
git clone https://github.com/sogis/openshift-templates.git
cd pgwatch2
```
### Steps to configure your database for monitoring

As a base requirement you'll need a login user (non-superuser suggested) for connecting to your PostgreSQL servers and fetching metrics queries.
Using a user named "pgwatch2" is recommended though, as otherwise your might need to adjust some scripts for advanced monitoring options,
in case an unpriveleged monitoring account is used.  More documentation on that can be found [here](https://pgwatch2.readthedocs.io/en/latest/preparing_databases.html).

```sql
CREATE ROLE pgwatch2 WITH LOGIN PASSWORD 'secret';
-- NB! For very important databases it might make sense to ensure that the user
-- account used for monitoring can only open a limited number of connections (there are according checks in code also though)
ALTER ROLE pgwatch2 CONNECTION LIMIT 6;
GRANT pg_monitor TO pgwatch2;   -- system role available for v10+ servers to reduce superuser usage
```

Additionally, for extra insights on "to be monitored" databases, it's recommended to install and activate the [pg_stat_statement](https://www.postgresql.org/docs/12/pgstatstatements.html)
contrib extension and enable the [track_io_timing](https://www.postgresql.org/docs/current/static/runtime-config-statistics.html#GUC-TRACK-IO-TIMING)
parameter in server configuration.

### Helper functions to retrieve protected statistics and Integration of OS level metrics
##### first install the Python bindings for Postgres
```
apt install postgresql-plpython3-XY
apt install postgresqlXY-plpython3
psql -c "CREATE EXTENSION plpython3u" mydb
```
##### Install necessary helper functions on the monitored database `DBNAME`
```
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_backup_age_walg/9.1/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_psutil_mem/9.1/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_backup_psutil_cpu/9.1/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_psutil_disk/9.1/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_load_average/9.1/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_load_average_copy/9.1/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_psutil_disk_io_total/9.1/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_stat_statements/9.4/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_backup_age_pgbackrest/9.1/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_stat_activity/9.2/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_wal_size/10/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_table_bloat_approx_sql/12/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_smart_health_per_device/9.1/metric.sql
psql DBNAME -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_stat_replication/9.2/metric.sql
```
You need to create three pvcs with the template pgwatch_pvc.yaml. In production environment pvcs are created from the AIO on the Netapp filer 
``` 
oc process -p env=test -f pgwatch_pvc.yaml  | oc apply -f-
```
`openshift_deployment_template.yaml` is provided by pgwatch (https://github.com/cybertec-postgresql/pgwatch2.git). It's adapted to our infrastructure purposes.
When updating to a new pgwatch version first check in the pgwatch repo if this template has changed.

### Create secrets for pgwatch Web GUI and Grafana User
Create the following secret YAML files locally, in a directory outside the checked out Git repository. Replace the `xy` placeholders with the appropriate keepass values. Then, in each environment (integration, production) create the secrets by running
```
oc create -n PROJECTNAME -f FILENAME
```
webuser-secret.yaml.
```
apiVersion: v1
kind: Secret
metadata:
  name: webuser-secret-pw2
  labels:
    app: pgwatch
type: Opaque
stringData:
  PW2_WEBUSER: xy
  PW2_WEBPASSWORD: xy
```
grafanauser-secret.yaml
```
apiVersion: v1
kind: Secret
metadata:
  name: webuser-secret-pw2
  labels:
    app: pgwatch
type: Opaque
stringData:
  PW2_GRAFANAUSER: xy
  PW2_GRAFANAPASSWORD: xy
```
### Install pgwatch
Run
```
oc process -p ENV=environment-name -f openshift_deployment_template.yaml | oc apply -f-
```
