FROM nginx:1.31.6-alpine3.24

COPY index.html /usr/share/nginx/html/
COPY docker-entrypoint.d/40-dash0-web-config.sh /docker-entrypoint.d/
RUN chmod +x /docker-entrypoint.d/40-dash0-web-config.sh

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
