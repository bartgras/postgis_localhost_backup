# About

Builds docker image using base image mdillon/postgis.
Performs database backups to locally mapped folder.

Example docker-compose.yml config for both database and backup:

```
version: "2"
services:
  postgis:
    image: mdillon/postgis
    env_file:
      - postgis.env

  postgis_backup:
    image: postgis-backup
    restart: always
    volumes:
      - /mybackups_folder:/backups
    links:
      - postgis
    depends_on:
      - postgis
    env_file:
      - postgis.env
```

`postgis.env` should have following variables defined:
```
# Env variables for database and backup image
PGDATABASE=
PGHOST=
PGPORT=
PGUSER=
PGPASS=

# Env vars for backup image
POSTGRES_EXTRA_OPTS=-Z9 --blobs
SCHEDULE=@daily
BACKUP_KEEP_DAYS=10
BACKUP_KEEP_WEEKS=4
BACKUP_KEEP_MONTHS=6
```


## Cron

Uses `https://github.com/odise/go-cron/` for cron jobs.

Allows to specify time using standard cron format `* * * * * *` or use simplified command e.g. `@daily`

Details about simplified format: `https://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules`


## Manual backups

In order to perform backups at call time use (example for docker compose):
```
docker-compose exec postgis_backup bash backup.sh
```
