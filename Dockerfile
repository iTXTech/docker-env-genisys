FROM php:7-zts

RUN groupadd -r genisys && useradd -r -g genisys genisys

RUN apt-get update && apt-get install -y libyaml-0-2 --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN buildDeps=" \
		libyaml-dev \
	" \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-install -j"$(nproc)" sockets bcmath \
	&& pecl install channel://pecl.php.net/pthreads-3.1.6 channel://pecl.php.net/weakref-0.3.2 channel://pecl.php.net/yaml-2.0.0RC7 \
	&& docker-php-ext-enable pthreads weakref yaml \
	&& echo "phar.readonly = off" > /usr/local/etc/php/conf.d/phar.ini \
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps

RUN mkdir -p /srv/genisys && chown genisys:genisys /srv/genisys

VOLUME /srv/genisys
WORKDIR /srv/genisys
USER genisys
EXPOSE 19132
CMD ["php", "/srv/genisys/genisys.phar"]
