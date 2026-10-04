FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx curl wget ca-certificates git build-essential python3 \
    && npm install -g @deepseek-ai/dsh \
    && apt-get remove -y build-essential python3 \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m dsh && mkdir -p /home/dsh/workspace && chown -R dsh /home/dsh

COPY nginx.conf /etc/nginx/nginx.conf
COPY cordis.patch.yml /app/cordis.patch.yml
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
