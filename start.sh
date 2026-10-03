#!/bin/sh
chown -R dsh:dsh /home/dsh/.dsh /home/dsh/workspace

if [ -f /app/cordis.patch.yml ] && [ -d /home/dsh/.dsh/profiles/web ]; then
  cp /app/cordis.patch.yml /home/dsh/.dsh/profiles/web/cordis.patch.yml
  chown dsh:dsh /home/dsh/.dsh/profiles/web/cordis.patch.yml
  chmod 600 /home/dsh/.dsh/profiles/web/cordis.patch.yml
fi

su dsh -c "cd /home/dsh/workspace && dsh web --no-open --port 3080 --trusted-host midsh.duckdns.org" &
exec nginx -g 'daemon off;'
