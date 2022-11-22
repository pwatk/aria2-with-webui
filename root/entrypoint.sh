#!/bin/sh

TZ=${TZ:-UTC}
PUID=${PUID:-911}
PGID=${PGID:-911}
BT_SEEDING=${BT_SEEDING:-true}
IPV6=${IPV6:-false}

# set timezone
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone

# add user and group
getent group $PGID >/dev/null 2>&1 || addgroup -g $PGID aria2
getent passwd $PUID >/dev/null 2>&1 || adduser -u $PUID -G $(getent group $PGID | cut -d: -f1) -h /config -s /sbin/nologin -g Aria2 -D aria2

# create config
if [ ! -f /config/aria2.conf ]; then
	cat <<- EOF > /config/aria2.conf
		dir=/data
		input-file=/config/aria2.session
		save-session=/config/aria2.session
		dht-file-path=/config/dht.dat
		dht-file-path6=/config/dht6.dat
		netrc-path=/config/netrc
		
		log-level=notice
		
		enable-http-pipelining=true
		max-concurrent-downloads=3
		max-connection-per-server=10
		min-split-size=10M
		split=10
		continue=true
		max-overall-download-limit=0
		max-overall-upload-limit=1K
		
		max-tries=0
		retry-wait=30
		
		#seed-time=0
		
		#file-allocation=prealloc
		
		disable-ipv6=true
		
		#listen-port=6881-6999
		#dht-listen-port=6881-6999
		
		enable-rpc=true
		rpc-listen-all=true
		rpc-allow-origin-all=true
		rpc-listen-port=6800
		
		#rpc-secure=false
		#rpc-certificate=
		#rpc-private-key=
		#rpc-secret=
	EOF

	# prefer docker secret over environment variable
	if [ -n "$SECRET_FILE" ] && [ -r "$SECRET_FILE" ]; then
		sed -i "/rpc-secret/s|^.*$|rpc-secret=$(cat "$SECRET_FILE")|" /config/aria2.conf
	elif [ -n "$SECRET" ]; then
		sed -i "/rpc-secret/s|^.*$|rpc-secret=$SECRET|" /config/aria2.conf
	fi

	if  [ -n "$FILE_ALLOCATION" ]; then
		case "$FILE_ALLOCATION" in
			none|prealloc|trunc|falloc)
				sed -i "/file-allocation/s|^.*$|file-allocation=$FILE_ALLOCATION|" /config/aria2.conf
			;;
		esac
	fi

	if [ "$IPV6" = "true" ]; then
		sed -i "/disable-ipv6/s|^.*$|disable-ipv6=false|" /config/aria2.conf
	fi

	if [ "$BT_SEEDING" = "false" ]; then
		sed -i "/seed-time/s|^.*$|seed-time=0|" /config/aria2.conf
	fi
fi

# fix permissions
touch \
	/config/aria2.log \
	/config/aria2.session \
	/config/bt-tracker-updater.log \
	/config/netrc

chown -R $PUID:$PGID /config

chmod 0600 /config/netrc
chmod 0640 /config/aria2.conf
chmod 0664 /config/bt-tracker-updater.log
chmod 0755 /usr/bin/bt-tracker-updater

# start daily cron job to update BitTorrent trackers
ln -sf /usr/bin/bt-tracker-updater /etc/periodic/daily/bt-tracker-updater

addgroup cron aria2

su-exec cron crond -l2 -b

(
	until [ -n "$(ps | grep aria2c | grep -v grep)" ]; do
		sleep 5s
	done

	bt-tracker-updater
) &

# start AriaNg
start_darkhttpd () {
	darkhttpd /www --chroot --port 80 --uid darkhttpd --gid nogroup --no-listing --no-server-id --daemon "$@"
}

if [ "$IPV6" = "true" ]; then
	start_darkhttpd --ipv6
else
	start_darkhttpd
fi

# start Aria2
exec su-exec $PUID:$PGID aria2c --conf-path=/config/aria2.conf --log=/config/aria2.log >/dev/null 2>&1
