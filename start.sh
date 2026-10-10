#!/bin/sh
# No usamos "set -e" para que un fallo menor no tumbe el contenedor.
# Los pasos críticos se validan manualmente.

echo "Preparando directorios..."
mkdir -p \
  /home/dsh/.dsh \
  /home/dsh/.claude \
  /home/dsh/.claude/skills \
  /home/dsh/.claude-mem \
  /home/dsh/.local/bin \
  /home/dsh/workspace \
  /home/dsh/.ssh \
  /tmp/dsh-credentials

echo "Preparando settings..."
if [ -f /app/settings.yaml ]; then
  cp /app/settings.yaml /home/dsh/workspace/settings.yaml
  cp /app/settings.yaml /home/dsh/.dsh/settings.yaml.imported
fi

echo "Configurando permisos..."
chown -R dsh:dsh \
  /home/dsh/.dsh \
  /home/dsh/.claude \
  /home/dsh/.claude-mem \
  /home/dsh/.local \
  /home/dsh/workspace \
  /tmp/dsh-credentials 2>/dev/null || true

chown dsh:dsh /home/dsh/.ssh 2>/dev/null || true
chmod 700 /home/dsh/.ssh /tmp/dsh-credentials 2>/dev/null || true

if [ -f /app/cordis.patch.yml ] && [ -d /home/dsh/.dsh/profiles/web ]; then
  echo "Aplicando configuración cordis..."
  cp /app/cordis.patch.yml /home/dsh/.dsh/profiles/web/cordis.patch.yml
  chown dsh:dsh /home/dsh/.dsh/profiles/web/cordis.patch.yml
  chmod 600 /home/dsh/.dsh/profiles/web/cordis.patch.yml
else
  echo "Aviso: perfil 'web' aún no existe, se omite cordis.patch.yml"
fi

# Si un volumen tapó /home/dsh y graphify desapareció, lo reinstala
echo "Verificando graphify..."
su dsh -s /bin/sh -c '
  export PATH="/home/dsh/.local/bin:$PATH"
  if ! command -v graphify >/dev/null 2>&1; then
    echo "graphify no encontrado, reinstalando..."
    python3 -m pip install --user --break-system-packages graphifyy \
      && graphify install \
      || echo "Aviso: no se pudo reinstalar graphify"
  else
    echo "graphify OK"
  fi
'

echo "Iniciando Claude-Mem con Pateway..."
if [ -z "$PATEWAY_API_KEY" ]; then
  echo "Aviso: PATEWAY_API_KEY no está definida, Claude-Mem no se iniciará"
else
  export CLAUDE_MEM_PROVIDER="openai-compatible"
  export CLAUDE_MEM_OPENAI_COMPAT_PRESET="custom"
  export CLAUDE_MEM_OPENAI_COMPAT_API_KEY="$PATEWAY_API_KEY"
  export CLAUDE_MEM_OPENAI_COMPAT_BASE_URL="https://api.pateway.ai/v1"
  export CLAUDE_MEM_OPENAI_COMPAT_MODEL="gpt-6-luna"
  export CLAUDE_MEM_RUNTIME="worker"

  # su -p conserva las variables exportadas arriba (incluida la API key)
  su -p dsh -s /bin/sh -c '
    export HOME=/home/dsh
    export PATH="/home/dsh/.local/bin:/home/dsh/.bun/bin:$PATH"
    exec npx --yes claude-mem start >> /home/dsh/.claude-mem/worker.log 2>&1
  ' &
fi

echo "Levantando DSH en puerto 3080..."
export DISABLE_LANDLOCK=1

su -p dsh -s /bin/sh -c '
  export HOME=/home/dsh
  export PATH="/home/dsh/.local/bin:/home/dsh/.bun/bin:$PATH"
  cd /home/dsh/workspace && \
  exec dsh web --no-open --port 3080 --trusted-host midsh.duckdns.org
' &

# Pequeña espera para que DSH tenga tiempo de abrir el puerto
sleep 3

echo "Levantando nginx..."
exec nginx -g "daemon off;"
