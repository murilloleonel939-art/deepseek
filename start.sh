#!/bin/sh
set -e

echo "Preparando settings..."
mkdir -p \
  /home/dsh/.dsh \
  /home/dsh/workspace \
  /home/dsh/.claude-mem

if [ -f /app/settings.yaml ]; then
  cp /app/settings.yaml /home/dsh/workspace/settings.yaml
  cp /app/settings.yaml /home/dsh/.dsh/settings.yaml.imported
fi

echo "Configurando permisos..."
chown -R dsh:dsh \
  /home/dsh/.dsh \
  /home/dsh/.claude \
  /home/dsh/.claude-mem \
  /home/dsh/workspace

if [ -f /app/cordis.patch.yml ] && [ -d /home/dsh/.dsh/profiles/web ]; then
  echo "Aplicando configuración..."
  cp /app/cordis.patch.yml \
    /home/dsh/.dsh/profiles/web/cordis.patch.yml

  chown dsh:dsh \
    /home/dsh/.dsh/profiles/web/cordis.patch.yml

  chmod 600 \
    /home/dsh/.dsh/profiles/web/cordis.patch.yml
fi

echo "Iniciando Claude-Mem con Pateway..."

su dsh -s /bin/sh -c '
  export CLAUDE_MEM_PROVIDER="openai-compatible"
  export CLAUDE_MEM_OPENAI_COMPAT_PRESET="custom"
  export CLAUDE_MEM_OPENAI_COMPAT_API_KEY="$PATEWAY_API_KEY"
  export CLAUDE_MEM_OPENAI_COMPAT_BASE_URL="https://api.pateway.ai/v1"
  export CLAUDE_MEM_OPENAI_COMPAT_MODEL="gpt-6-luna"
  export CLAUDE_MEM_RUNTIME="worker"

  npx --yes claude-mem start \
    >> /home/dsh/.claude-mem/worker.log 2>&1
' &

echo "Levantando DSH en puerto 3080..."
export DISABLE_LANDLOCK=1

su dsh -s /bin/sh -c \
  "cd /home/dsh/workspace && \
   dsh web --no-open --port 3080 --trusted-host midsh.duckdns.org" &

echo "Levantando nginx..."
exec nginx -g "daemon off;"
