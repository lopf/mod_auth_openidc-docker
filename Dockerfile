FROM httpd:2.4
ARG MOD_AUTH_OPENIDC_VERSION=2.4.6
ARG CJOSE_VERSION=0.6.1.3
RUN set -exu; \
    apt-get update; \
    apt-get install -y libhiredis0.14 ca-certificates; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get install -y --no-install-recommends \
		bzip2 \
		ca-certificates \
		dirmngr \
		dpkg-dev \
		gcc \
		gnupg \
		libapr1-dev \
		libaprutil1-dev \
		libbrotli-dev \
		libcurl4-openssl-dev \
		libjansson-dev \
		liblua5.2-dev \
		libnghttp2-dev \
		libpcre3-dev \
		libssl-dev \
		libxml2-dev \
		make \
		wget \
		zlib1g-dev \
                libhiredis-dev \
                doxygen \
                file \
                check; \
    mkdir -p /build; \
    cd /build; \
    wget https://github.com/zmartzone/mod_auth_openidc/releases/download/v${MOD_AUTH_OPENIDC_VERSION}/mod_auth_openidc-${MOD_AUTH_OPENIDC_VERSION}.tar.gz; \
    wget https://github.com/zmartzone/cjose/archive/${CJOSE_VERSION}.tar.gz; \
    tar xzf ${CJOSE_VERSION}.tar.gz; \
    cd /build/cjose-${CJOSE_VERSION}; \
    ./configure && make && make install; \
    cd /build; \
    tar xzf mod_auth_openidc-${MOD_AUTH_OPENIDC_VERSION}.tar.gz; \
    cd /build/mod_auth_openidc-${MOD_AUTH_OPENIDC_VERSION}; \
    ./configure --with-apxs2=/usr/local/apache2/bin/apxs && \
    make -j4; \
    make install; \
    cd / && rm -rf /build; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
    		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -r /var/lib/apt/lists/*; \
    \
    httpd -v
