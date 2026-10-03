#!/bin/sh
su dsh -c "cd /home/dsh/workspace && dsh web --no-open --port 3080" &
exec nginx -g 'daemon off;'
