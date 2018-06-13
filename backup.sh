#! /bin/sh

set -e

if [ "${PGDATABASE}" = "**None**" ]; then
  echo "You need to set the PGDATABASE environment variable."
  exit 1
fi

if [ "${PGHOST}" = "**None**" ]; then
  if [ -n "${PGPORT_5432_TCP_ADDR}" ]; then
    PGHOST=$POSTGRES_PORT_5432_TCP_ADDR
    PGPORT=$PGPORT_5432_TCP_PORT
  else
    echo "You need to set the PGHOST environment variable."
    exit 1
  fi
fi

if [ "${PGUSER}" = "**None**" ]; then
  echo "You need to set the PGUSER environment variable."
  exit 1
fi

if [ "${PGPASS}" = "**None**" ]; then
  echo "You need to set the PGPASS environment variable or link to a container named POSTGRES."
  exit 1
fi

#Proces vars
export PGPASSWORD=$PGPASS
export PGPASS=$PGPASS
PGHOST_OPTS="-h $PGHOST -p $PGPORT -U $PGUSER $POSTGRES_EXTRA_OPTS"
KEEP_DAYS=$BACKUP_KEEP_DAYS
KEEP_WEEKS=`expr $((($BACKUP_KEEP_WEEKS * 7) + 1))`
KEEP_MONTHS=`expr $((($BACKUP_KEEP_MONTHS * 31) + 1))`

#Initialize filename vers and dirs
DFILE="$BACKUP_DIR/daily/$PGDATABASE-`date +%Y%m%d-%H%M%S`.sql.gz"
WFILE="$BACKUP_DIR/weekly/$PGDATABASE-`date +%G%V`.sql.gz"
MFILE="$BACKUP_DIR/monthly/$PGDATABASE-`date +%Y%m`.sql.gz"
mkdir -p "$BACKUP_DIR/daily/" "$BACKUP_DIR/weekly/" "$BACKUP_DIR/monthly/"

#Create dump
echo "Creating dump of ${PGDATABASE} database from ${PGHOST}..."
pg_dump -f "$DFILE" $PGHOST_OPTS $PGDATABASE

#Copy (hardlink) for each entry
ln -vf "$DFILE" "$WFILE"
ln -vf "$DFILE" "$MFILE"

#Clean old files
find "$BACKUP_DIR/daily" -maxdepth 1 -mtime +$KEEP_DAYS -name "$PGDATABASE-*.sql*" -exec rm -rf '{}' ';'
find "$BACKUP_DIR/weekly" -maxdepth 1 -mtime +$KEEP_WEEKS -name "$PGDATABASE-*.sql*" -exec rm -rf '{}' ';'
find "$BACKUP_DIR/monthly" -maxdepth 1 -mtime +$KEEP_MONTHS -name "$PGDATABASE-*.sql*" -exec rm -rf '{}' ';'

echo "SQL backup uploaded successfully"