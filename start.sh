#!/bin/sh
set -e

echo "Configurando permisos..."
chown -R dsh:dsh /home/dsh/.dsh /home/dsh/workspace

if [ -f /app/cordis.patch.yml ] && [ -d /home/dsh/.dsh/profiles/web ]; then
  echo "Aplicando configuración..."
  cp /app/cordis.patch.yml /home/dsh/.dsh/profiles/web/cordis.patch.yml
  chown dsh:dsh /home/dsh/.dsh/profiles/web/cordis.patch.yml
  chmod 600 /home/dsh/.dsh/profiles/web/cordis.patch.yml
fi

echo "Levantando DSH en puerto 3080 (sin landlock)..."
export DISABLE_LANDLOCK=1
su dsh -c "cd /home/dsh/workspace && dsh web --no-open --port 3080 --trusted-host midsh.duckdns.org" &

echo "Levantando nginx..."
exec nginx -g 'daemon off;'
