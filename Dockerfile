FROM alpine

LABEL maintainer pwatk

ENV \
PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
HOME="/root" \
TERM="xterm" \
BT_TRACKER="true" \
BT_SEEDING="true" \
IPV6="false" \
WEBUI="AriaNg"

RUN \
 echo "**** install build packages ****" && \
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
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	bash \
	c-ares \
	ca-certificates \
	coreutils \
	curl \
	darkhttpd \
	gnutls \
	libgcc \
	libssh2 \
	libstdc++ \
	libxml2 \	
	logrotate \
	nettle \
	procps \
	shadow \
	sqlite-libs \
	tzdata \
	zlib && \
 echo "**** create user and directories ****" && \
 useradd -u 911 -U -G users -d /config -s /bin/false abc && \
 mkdir -p \
	/app \
	/config/log \
	/defaults && \
 echo "**** fix logrotate ****" && \
 sed -i "s|/var/log/messages {}.*| |" /etc/logrotate.conf && \
 sed -i "s|logrotate /etc/logrotate.conf|logrotate /etc/logrotate.conf -s /config/log/logrotate.status|" \
	/etc/periodic/daily/logrotate && \
 echo "**** install s6-overlay ****" && \
 QEMU_ARCH="$(uname -m)" && \
 case "${QEMU_ARCH}" in \
	x86_64) S6_ARCH='amd64';; \
	aarch64) S6_ARCH='aarch64';; \
	armv7l) S6_ARCH='armhf';; \
	*) echo "!!! unsupported architecture - $QEMU_ARCH !!!"; exit 1 ;; \
 esac && \
 S6_RELEASE=$(curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl \
	-o /tmp/s6-overlay-${S6_ARCH}.tar.gz -L \
	https://github.com/just-containers/s6-overlay/releases/download/${S6_RELEASE}/s6-overlay-${S6_ARCH}.tar.gz && \
 tar xzf /tmp/s6-overlay-${S6_ARCH}.tar.gz -C / && \
 echo "**** install AriaNg ****" && \
 mkdir -p /app/AriaNg && \
 ARIANG_RELEASE=$(curl -sX GET "https://api.github.com/repos/mayswind/AriaNg/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl \
	-o /tmp/AriaNg.zip -L \
	https://github.com/mayswind/AriaNg/releases/download/${ARIANG_RELEASE}/AriaNg-${ARIANG_RELEASE}.zip && \
 unzip /tmp/AriaNg.zip -d /app/AriaNg && \
 echo "**** install webui-aria2 ****" && \
 git clone https://github.com/ziahamza/webui-aria2 /tmp/webui-aria2 && \
 cp -a /tmp/webui-aria2/docs /app/webui-aria2 && \
 cp -a /tmp/webui-aria2/favicon.ico /app/webui-aria2/favicon.ico && \
 sed -i "s|../favicon.ico|./favicon.ico|g" /app/webui-aria2/index.html && \
 echo "**** install aria2 ****" && \
 ARIA2_RELEASE=$(curl -sX GET "https://api.github.com/repos/aria2/aria2/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl \
	-o /tmp/aria2.tar.gz -L \
	https://github.com/aria2/aria2/releases/download/${ARIA2_RELEASE}/${ARIA2_RELEASE/release/aria2}.tar.gz && \
 tar xzf /tmp/aria2.tar.gz -C /tmp/ && \
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
 echo "**** cleanup ****" && \
 rm -rf /tmp/* && \
 apk del --purge build-dependencies

COPY root/ /

VOLUME /config /data
EXPOSE 80 6800 6881-6999 6881-6999/udp

ENTRYPOINT ["/init"]
