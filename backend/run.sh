#!/bin/bash
set -e
# Cleanup
# podman rm -f syds-droemmerejse-apache syds-droemmerejse-mysql; podman volume rm -f syds-droemmerejse-mysql-data

MYSQL_NAME="syds-droemmerejse-mysql"
APACHE_NAME="syds-droemmerejse-apache"
DB_VOLUME="syds-droemmerejse-mysql-data"
NETWORK_NAME="syds-droemmerejse-network"
WEB_ROOT="$(pwd)"
DB_SQL="$(pwd)/provision/Db.sql"

# Create network
if ! podman network exists "$NETWORK_NAME"; then
  echo "Creating network..."
  podman network create "$NETWORK_NAME"
fi

# Setup MySQL
if podman container exists "$MYSQL_NAME" && [ "$(podman inspect -f '{{.State.Running}}' "$MYSQL_NAME")" == "true" ]; then
  echo "MySQL container already running, skipping setup..."
else
  if ! podman volume exists "$DB_VOLUME"; then
    echo "Creating MySQL volume..."
    podman volume create "$DB_VOLUME"
  fi
  
  if podman container exists "$MYSQL_NAME"; then
    echo "Removing stopped MySQL container..."
    podman rm -f "$MYSQL_NAME"
  fi
  
  echo "Starting MySQL container..."
  podman run -d --name "$MYSQL_NAME" \
    --network "$NETWORK_NAME" \
    -e MYSQL_ROOT_PASSWORD=SuperSecret \
    -e MYSQL_ROOT_HOST=% \
    -v "$DB_VOLUME":/var/lib/mysql \
    -p 3306:3306 \
    docker.io/library/mysql:latest
  
  echo "Waiting for MySQL to be fully ready..."
  until podman exec "$MYSQL_NAME" mysql -u root -pSuperSecret -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
  done
  
  echo "Provisioning MySQL database..."
  podman cp "$DB_SQL" "$MYSQL_NAME":/tmp/Db.sql
  podman exec "$MYSQL_NAME" bash -c "mysql -u root -pSuperSecret -h 127.0.0.1 < /tmp/Db.sql"
fi

# Setup apache
if podman container exists "$APACHE_NAME" && [ "$(podman inspect -f '{{.State.Running}}' "$APACHE_NAME")" == "true" ]; then
  echo "Apache container already running, skipping setup..."
else
  if podman container exists "$APACHE_NAME"; then
    echo "Removing stopped Apache container..."
    podman rm -f "$APACHE_NAME"
  fi
  
  echo "Starting Apache container..."
  podman run -d --name "$APACHE_NAME" \
    --network "$NETWORK_NAME" \
    -p 8080:80 \
    --privileged \
    -v "$WEB_ROOT":/var/www/html:Z \
    docker.io/library/php:8.2-apache \
    sh -c "apt-get update && apt-get install -y default-libmysqlclient-dev && docker-php-ext-install mysqli && apache2-foreground"
fi

echo "Setup complete!"
echo "MySQL: localhost:3306"
echo "Apache: http://localhost:8080"