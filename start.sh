#!/bin/sh
# Un volumen nuevo llega con dueño root: se lo damos al usuario dsh
chown -R dsh:dsh /home/dsh/.dsh /home/dsh/workspace

# Copia el settings.yaml del repo solo si el volumen aún no tiene uno
if [ ! -f /home/dsh/.dsh/settings.yaml ] && [ -f /app/settings.yaml ]; then
  cp /app/settings.yaml /home/dsh/.dsh/settings.yaml
  chown dsh:dsh /home/dsh/.dsh/settings.yaml
fi

su dsh -c "cd /home/dsh/workspace && dsh web --no-open --port 3080 --trusted-host midsh.duckdns.org" &
exec nginx -g 'daemon off;'
