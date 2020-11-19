# Install or Update pgwatch2 in Openshift
Checkout Template repo
```
git clone https://github.com/cybertec-postgresql/pgwatch2.git
cd pgwatch2
```
Install necessary helper functions
```
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_backup_age_walg/9.1/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_psutil_mem/9.1/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_backup_psutil_cpu/9.1/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_psutil_disk/9.1/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_load_average/9.1/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_load_average_copy/9.1/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_psutil_disk_io_total/9.1/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_stat_statements/9.4/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_backup_age_pgbackrest/9.1/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_stat_activity/9.2/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_wal_size/10/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_table_bloat_approx_sql/12/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_smart_health_per_device/9.1/metric.sql
psql dbname -h dbserver -U username -W -c 'set role role of the superuser' -f pgwatch2/metrics/00_helpers/get_stat_replication/9.2/metric.sql
```

run
``` 
oc process -p env=test -p version=1.5.1 -f pgwatch.yaml  | oc apply -f-
```
