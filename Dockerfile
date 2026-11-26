# syntax=docker/dockerfile:1

FROM debian:bookworm-slim AS flutter
ARG FLUTTER_VERSION=3.50.1
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter config --no-analytics --no-cli-animations && flutter precache --web

FROM flutter AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

FROM nginxinc/nginx-unprivileged:1.31-alpine
USER root
RUN chown 101:101 /usr/share/nginx/html
USER 101
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --chmod=755 docker/gerar-config.sh /docker-entrypoint.d/40-gerar-config.sh
COPY --from=build --chown=101:101 /app/build/web /usr/share/nginx/html
ENV API_URL=http://localhost:8080
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:8080/config.json || exit 1
