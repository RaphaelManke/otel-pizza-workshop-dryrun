#!/bin/sh
# Injects the Dash0 Web SDK configuration into index.html at container start, so
# the auth token is never baked into the image or committed to git.
#
# DASH0_WEB_ENDPOINT / DASH0_WEB_AUTH_TOKEN win when set; otherwise the OTLP/HTTP
# endpoint is derived from DASH0_ENDPOINT (its gRPC port is dropped) and the
# regular DASH0_AUTH_TOKEN is used.
set -eu

HTML=/usr/share/nginx/html/index.html

endpoint="${DASH0_WEB_ENDPOINT:-}"
if [ -z "$endpoint" ] && [ -n "${DASH0_ENDPOINT:-}" ]; then
  endpoint=$(printf '%s' "$DASH0_ENDPOINT" | sed -e 's#^grpc://#https://#' -e 's#:4317$##' -e 's#/*$##')
fi

token="${DASH0_WEB_AUTH_TOKEN:-${DASH0_AUTH_TOKEN:-}}"
environment="${DASH0_ENVIRONMENT:-workshop}"

escape() {
  printf '%s' "$1" | sed -e 's#[\\&/]#\\&#g'
}

if [ -n "$endpoint" ] && [ -n "$token" ]; then
  echo "dash0: website monitoring enabled, sending to $endpoint"
else
  echo "dash0: DASH0_ENDPOINT / DASH0_AUTH_TOKEN not set in pizza-app/.env - website monitoring disabled"
fi

sed -i \
  -e "s/__DASH0_WEB_ENDPOINT__/$(escape "$endpoint")/g" \
  -e "s/__DASH0_WEB_AUTH_TOKEN__/$(escape "$token")/g" \
  -e "s/__DASH0_ENVIRONMENT__/$(escape "$environment")/g" \
  "$HTML"
