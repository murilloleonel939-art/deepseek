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
    libseccomp2 \
    libc6 \
    libstdc++6 \
    libgcc1 \
    && npm cache clean --force \
    && npm install -g @deepseek-ai/dsh@0.2.0-rc.2 --verbose \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash dsh \
    && mkdir -p \
        /home/dsh/workspace \
        /home/dsh/.dsh \
        /home/dsh/.ssh \
        /tmp/dsh-credentials \
    && chown -R dsh:dsh /home/dsh /tmp/dsh-credentials \
    && chmod 700 /home/dsh/.ssh /tmp/dsh-credentials

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

ENV HOME=/home/dsh
ENV PYTHONUNBUFFERED=1
ENV GIT_TERMINAL_PROMPT=0

CMD ["/start.sh"]
