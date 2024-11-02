FROM alpine

LABEL org.opencontainers.image.vendor="pwatk"
LABEL org.opencontainers.image.title="aria2-with-webui"
LABEL org.opencontainers.image.description="Aria2 with AriaNg web frontend"

RUN \
	apk add --no-cache \
		aria2 \
		ca-certificates \
		curl \
		darkhttpd \
		logrotate \
		su-exec \
		tzdata && \
	mkdir -p /www/ && \
	ARIANG_RELEASE=$(curl -sX GET "https://api.github.com/repos/mayswind/AriaNg/releases/latest" \
		| awk '/tag_name/{print $4;exit}' FS='[""]') && \
	curl \
		-o /tmp/AriaNg.zip -L \
		https://github.com/mayswind/AriaNg/releases/download/${ARIANG_RELEASE}/AriaNg-${ARIANG_RELEASE}.zip && \
	unzip /tmp/AriaNg.zip -d /www && \
	rm -rf /tmp/*

COPY root/ /

VOLUME /config /data
EXPOSE 80 6800 6881-6999 6881-6999/udp

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=20s CMD /usr/local/bin/healthcheck
