#!/bin/sh
set -e
 
echo "Preparando settings..."
mkdir -p /home/dsh/.dsh /home/dsh/workspace
# Copia desde la imagen (/app) para que funcione aunque haya volúmenes montados
if [ -f /app/settings.yaml ]; then
  cp /app/settings.yaml /home/dsh/workspace/settings.yaml
  cp /app/settings.yaml /home/dsh/.dsh/settings.yaml.imported
fi
 
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
