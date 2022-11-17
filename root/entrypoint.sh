#!/bin/bash

TZ=${TZ:-UTC}
PUID=${PUID:-1000}
PGID=${PGID:-1000}
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
	cp /defaults/aria2.conf /config/aria2.conf

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

touch \
	/config/aria2.session \
	/config/netrc

chown -R $PUID:$PGID /config
chmod 0600 /config/netrc

# start daily cron job to update BitTorrent trackers
chmod 0755 /usr/bin/bt-tracker-updater
ln -sf /usr/bin/bt-tracker-updater /etc/periodic/daily/bt-tracker-updater 

crond -l2 -b

(
	until [ -n "$(ps | grep aria2c | grep -v grep)" ]; do
		sleep 5s
	done

	bt-tracker-updater
) &

# start AriaNg
if [ "$IPV6" = "true" ]; then
	ipv6="--ipv6"
fi

darkhttpd /www --chroot --port 80 --uid darkhttpd --gid nogroup --no-listing --no-server-id --daemon $ipv6

# start Aria2
su-exec $PUID:$PGID aria2c --conf-path=/config/aria2.conf --log=/config/aria2.log >/dev/null 2>&1
