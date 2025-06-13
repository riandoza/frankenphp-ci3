FROM dunglas/frankenphp:1-php8.4.8-alpine

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}
# Set Caddy server name to "http://" to serve on 80 and not 443
# Read more: https://frankenphp.dev/docs/config/#environment-variables
ENV SERVER_NAME=:80
ENV TZ=Asia/Jakarta
ARG USER=laravel

WORKDIR /app

# RUN useradd ${USER}; \
# 	setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp; \
# 	chown -R ${USER}:${USER} /data/caddy && chown -R ${USER}:${USER} /config/caddy

# Debian
# COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system laravel; \
	adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel; \
	setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp; \
	chown -R ${UID}:${GID} /data/caddy && chown -R ${USER}:${USER} /config/caddy

RUN install-php-extensions \
	pdo_mysql \
	redis \
	zip \
	opcache \
	intl \
	pcntl \
	gd

# Production:
# RUN cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

# Or development:
RUN cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

USER ${USER}

# CMD ["frankenphp", "php-server", "-r", "/app"]
CMD [ "frankenphp", "run", "--config", "/etc/caddy/Caddyfile", "--watch" ]
