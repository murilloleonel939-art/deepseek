#!/bin/sh
su dsh -c "cd /home/dsh/workspace && dsh web --no-open --port 3080 --trusted-host midsh.duckdns.org" &
exec nginx -g 'daemon off;'
