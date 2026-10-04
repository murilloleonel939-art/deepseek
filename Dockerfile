FROM node:22

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx curl wget ca-certificates git build-essential python3 libseccomp2 \
    libc6 libstdc++6 libgcc1 \
    && npm cache clean --force \
    && npm install -g @deepseek-ai/dsh --verbose \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m dsh && mkdir -p /home/dsh/workspace && chown -R dsh /home/dsh

# ✅ COPIA settings.yaml
COPY settings.yaml /app/settings.yaml

COPY nginx.conf /etc/nginx/nginx.conf
COPY cordis.patch.yml /app/cordis.patch.yml
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
