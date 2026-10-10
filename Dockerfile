FROM node:22

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    curl \
    wget \
    ca-certificates \
    git \
    openssh-client \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    libseccomp2 \
    libc6 \
    libstdc++6 \
    libgcc1 \
    && npm install -g @deepseek-ai/dsh@0.2.0-rc.2 \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/* \
    && corepack enable \
    && corepack prepare pnpm@latest --activate \
    && useradd -m -s /bin/bash dsh \
    && mkdir -p \
        /home/dsh/workspace \
        /home/dsh/.dsh \
        /home/dsh/.claude \
        /home/dsh/.claude/skills \
        /home/dsh/.ssh \
        /tmp/dsh-credentials \
    && chown -R dsh:dsh /home/dsh /tmp/dsh-credentials \
    && chmod 700 /home/dsh/.ssh /tmp/dsh-credentials

ENV HOME=/home/dsh
ENV PATH="/home/dsh/.local/bin:/home/dsh/.bun/bin:${PATH}"
ENV PYTHONUNBUFFERED=1
ENV GIT_TERMINAL_PROMPT=0
ENV CLAUDE_MEM_ONLINE_OPTIN=false

USER dsh

RUN python3 -m pip install --user --break-system-packages graphifyy \
    && graphify install

RUN npx --yes claude-mem install \
    --ide dsh \
    --dsh-profile web \
    --provider host

USER root

COPY settings.yaml /app/settings.yaml
COPY settings.yaml /home/dsh/workspace/settings.yaml
COPY settings.yaml /home/dsh/.dsh/settings.yaml.imported

RUN chown dsh:dsh \
    /home/dsh/workspace/settings.yaml \
    /home/dsh/.dsh/settings.yaml.imported

COPY nginx.conf /etc/nginx/nginx.conf
COPY cordis.patch.yml /app/cordis.patch.yml
COPY start.sh /start.sh

RUN chmod 755 /start.sh

EXPOSE 80

CMD ["/start.sh"]
