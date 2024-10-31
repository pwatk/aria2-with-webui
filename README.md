# Aria2 with AriaNg web frontend

## Description

[Aria2](https://github.com/aria2/aria2) is a command-line download utility that supports HTTP(S), FTP, SFTP and BitTorrent. [AriaNg](https://github.com/mayswind/AriaNg) is a modern web frontend making aria2 easier to use.

## [Docker Compose](https://docs.docker.com/compose/compose-file/)

```yaml
services:
  aria2-with-webui:
    container_name: aria2-with-webui
    image: pwatk/aria2-with-webui
    build: https://github.com/pwatk/docker-aria2-with-webui.git
    restart: unless-stopped
    ports:
      - "80:80"
      - "6800:6800"
      - "6881-6999:6881-6999"           # optional
      - "6881-6999:6881-6999/udp"       # optional
    volumes:
      - /path/to/downloads:/data
      - /path/to/config:/config         # optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - FILE_ALLOCATION=falloc          # optional
      - SECRET=password                 # optional
      - IPV6=true                       # optional
      - BT_TRACKER_URL=http...          # optional
```

## Port numbers

| Port(s) | Function |
| :----: | --- |
| `80` | Web interface |
| `6800` | [RPC listening port](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-rpc-listen-port) |
| `6881-6999` | [BitTorrent listening ports](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-listen-port) |
| `6881-6999/udp` | [DHT listening ports](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-dht-listen-port) |

## Environment variables

| Variable | Function |
| :----: | --- |
| `PUID` | [UID](https://en.wikipedia.org/wiki/Passwd "A user identifier, often abbreviated to user ID or UID") of a user on host machine - Owner of files and directories inside volumes. **Default: 1000** |
| `PGID` | [GID](https://en.wikipedia.org/wiki/Group_identifier "A group identifier, often abbreviated to GID") of group on host machine - Group assigned to files and directories inside volumes. **Default: 1000** |
| `TZ` | Specify a [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to use e.g. Europe/London. **Default: undefined** |
| `FILE_ALLOCATION` | Sets the [file allocation](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-file-allocation "--file-allocation=<METHOD>") method. Available values: *none, prealloc, trunc or falloc*. **Default: undefined** |
| `SECRET` | Set [RPC secret](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-rpc-secret "--rpc-secret=<TOKEN>") authorization token (overridden by SECRET_FILE). **Default: undefined** |
| `SECRET_FILE` | Set [RPC secret](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-rpc-secret "--rpc-secret=<TOKEN>") authorization token using [Docker secrets](https://docs.docker.com/compose/compose-file/#secrets). e.g. /run/secrets/aria2-rpc-secret. **Default: undefined** |
| `IPV6` | Enable or disable [IPv6](https://en.wikipedia.org/wiki/IPv6) support for both [Aria2](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-disable-ipv6) and the [web server](https://wiki.alpinelinux.org/wiki/Darkhttpd#man_darkhttpd). Available values: *true or false*. **Default: false** |
| `BT_TRACKER_URL` | Specify a URL from which to download a list of [BitTorrent trackers](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-bt-tracker) (comma or newline seperated). **Default: undefined** |

## Notes
If a secure (SSL/TLS) connection is required, the reverse proxy [SWAG](https://github.com/linuxserver/docker-swag) includes a [configuration file](https://github.com/linuxserver/reverse-proxy-confs) for this purpose.

This project was influenced by [onisuly/docker-aria2-with-webui](https://github.com/onisuly/docker-aria2-with-webui)
