FROM mdillon/postgis

RUN set -x \
	&& apt-get update \
	&& apt-get install -y curl \
	&& curl -L https://github.com/odise/go-cron/releases/download/v0.0.7/go-cron-linux.gz | zcat > /usr/local/bin/go-cron \
	&& chmod a+x /usr/local/bin/go-cron

ENV PGDATABASE **None**
ENV PGHOST **None**
ENV PGPORT 5432
ENV PGUSER **None**
ENV PGPASS **None**
ENV POSTGRES_EXTRA_OPTS '-Z9'
ENV SCHEDULE '@daily'
ENV BACKUP_DIR '/backups'
ENV BACKUP_KEEP_DAYS 7
ENV BACKUP_KEEP_WEEKS 4
ENV BACKUP_KEEP_MONTHS 6

COPY backup.sh /backup.sh

VOLUME /backups

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["exec /usr/local/bin/go-cron -s \"$SCHEDULE\" -p 80 -- /backup.sh"]

HEALTHCHECK --interval=5m --timeout=3s \
	CMD curl -f http://localhost/ || exit 1