#!/bin/sh
set -eu

url_escapada=$(printf '%s' "${API_URL}" | sed 's/\\/\\\\/g; s/"/\\"/g')
printf '{"apiUrl":"%s"}\n' "${url_escapada}" > /usr/share/nginx/html/config.json
