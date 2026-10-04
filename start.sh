#!/bin/sh
set -e

echo "Inicializando DSH..."
su dsh -c "dsh init --non-interactive" || true

echo "Configurando permisos..."
chown -R dsh:dsh /home/dsh/.dsh /home/dsh/workspace

if [ -f /app/cordis.patch.yml ] && [ -d /home/dsh/.dsh/profiles/web ]; then
  echo "Aplicando configuración..."
  cp /app/cordis.patch.yml /home/dsh/.dsh/profiles/web/cordis.patch.yml
  chown dsh:dsh /home/dsh/.dsh/profiles/web/cordis.patch.yml
  chmod 600 /home/dsh/.dsh/profiles/web/cordis.patch.yml
fi

echo "Levantando DSH en puerto 3080..."
su dsh -c "cd /home/dsh/workspace && dsh web --no-open --port 3080 --trusted-host midsh.duckdns.org" &

echo "Levantando nginx..."
exec nginx -g 'daemon off;'
