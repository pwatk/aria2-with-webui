FROM alpine

LABEL maintainer pwatk

RUN \
 echo "**** Install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	autoconf \
	automake \
	build-base \
	c-ares-dev \
	cppunit-dev \
	gettext-dev \
	git \
	gnutls-dev \
	libssh2-dev \
	libtool \
	libxml2-dev \
	nettle-dev \
	sqlite-dev \
	unzip \
	zlib-dev && \
 echo "**** Install runtime packages ****" && \
 apk add --no-cache \
	c-ares \
	ca-certificates \
	curl \
	darkhttpd \
	gnutls \
	libgcc \
	libssh2 \
	libstdc++ \
	libxml2 \
	logrotate \
	nettle \
	sqlite-libs \
	su-exec \
	tzdata \
	zlib && \
 echo "**** Create directories ****" && \
 mkdir -p \
	/config/log \
	/data \
	/www && \
 echo "**** Install AriaNg ****" && \
 ARIANG_RELEASE=$(curl -sX GET "https://api.github.com/repos/mayswind/AriaNg/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl \
	-o /tmp/AriaNg.zip -L \
	https://github.com/mayswind/AriaNg/releases/download/${ARIANG_RELEASE}/AriaNg-${ARIANG_RELEASE}.zip && \
 unzip /tmp/AriaNg.zip -d /www && \
 echo "**** Install Aria2 ****" && \
 ARIA2_RELEASE=$(curl -sX GET "https://api.github.com/repos/aria2/aria2/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl \
	-o /tmp/aria2.tar.gz -L \
	https://github.com/aria2/aria2/releases/download/${ARIA2_RELEASE}/${ARIA2_RELEASE/release/aria2}.tar.gz && \
 tar -xzf /tmp/aria2.tar.gz -C /tmp/ && \
 ( \
	 cd /tmp/${ARIA2_RELEASE/release/aria2} && \
	 autoreconf -i && \
	 ./configure \
		CFLAGS="-Os -s" \
		CXXFLAGS="-Os -s" \
		--prefix=/usr \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--localstatedir=/var \
		--disable-nls \
		--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt && \
	 make -j $(getconf _NPROCESSORS_ONLN) && \	
	 install -Dm 0755 src/aria2c /usr/bin/aria2c \
 ) && \
 echo "**** Cleanup ****" && \
 rm -rf /tmp/* && \
 apk del --purge build-dependencies

COPY root/ /

VOLUME /config /data
EXPOSE 80 6800 6881-6999 6881-6999/udp

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=5s --timeout=1s CMD ps | grep darkhttpd | grep -v grep || exit 1