#!/bin/sh
chown -R dsh:dsh /home/dsh/.dsh /home/dsh/workspace

if [ -f /app/settings.yaml ]; then
  cp /app/settings.yaml /home/dsh/.dsh/settings.yaml
  chown dsh:dsh /home/dsh/.dsh/settings.yaml
  rm -f /home/dsh/.dsh/settings.yaml.imported
fi

# Arranca dsh y captura el token
su dsh -c "cd /home/dsh/workspace && dsh web --no-open --port 3080 --trusted-host constructor.zottagroup.com 2>&1 | tee /tmp/dsh.log" &

# Espera a que dsh inicie y extrae el token
TOKEN=""
for i in $(seq 1 60); do
  TOKEN=$(grep -o 'token=[A-Za-z0-9_-]*' /tmp/dsh.log 2>/dev/null | head -1 | cut -d= -f2)
  [ -n "$TOKEN" ] && break
  sleep 1
done

# Reescribe nginx.conf con el token actual
sed -i "s|__TOKEN__|$TOKEN|" /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'
