#!/usr/bin/env bash
set -euo pipefail

if command -v mongod >/dev/null 2>&1; then
  :
else
  echo "Installing MongoDB..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq curl gnupg
  curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
  echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list >/dev/null
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org
fi

mkdir -p /tmp/mongodb-data /tmp/mongodb-log

if ! pgrep -x mongod >/dev/null 2>&1; then
  mongod --dbpath /tmp/mongodb-data --logpath /tmp/mongodb-log/mongod.log --bind_ip 127.0.0.1 --port 27017 --fork
fi

for _ in $(seq 1 30); do
  if mongosh --eval 'db.runCommand({ ping: 1 })' --quiet >/dev/null 2>&1; then
    exit 0
  fi
  sleep 1
done

echo "MongoDB failed to become ready" >&2
exit 1
