#!/bin/bash
set -e

cp /var/www/config/config.ini.orig /var/www/config/config.ini
sed -i "s/\${POSTGRES_HOST}/${POSTGRES_HOST}/g" /var/www/config/config.ini
sed -i "s/\${POSTGRES_DB}/${POSTGRES_DB}/g" /var/www/config/config.ini
sed -i "s/\${POSTGRES_USER}/${POSTGRES_USER}/g" /var/www/config/config.ini
sed -i "s/\${POSTGRES_PASSWORD}/${POSTGRES_PASSWORD}/g" /var/www/config/config.ini
sed -i "s/\${PDNS_API_HOST}/${PDNS_API_HOST}/g" /var/www/config/config.ini
sed -i "s/\${PDNS_API_KEY}/${PDNS_API_KEY}/g" /var/www/config/config.ini

mkdir -p /data

while ! nc -z "$POSTGRES_HOST" 5432; do
	echo "Waiting for database..."
	sleep 1
done

if [ ! -f /data/htpasswd ]; then

	echo "Creating admin user..."

	# trigger tables to be created
	php init.php >/dev/null

	# create admin user
	htpasswd -b -c /data/htpasswd "$ADMIN_USER" "$ADMIN_PASSWORD"
	PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "INSERT INTO \"user\" (uid, name, email, active, admin, auth_realm) VALUES ('admin', 'User Admin', 'admin@example.com', 1, 1, 'local')"

fi

if [[ ! -z "$1" ]]; then
    exec ${*}
else
    exec apache2-foreground
fi
