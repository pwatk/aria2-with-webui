# Aria2 with a web interface

## Description

[Aria2](https://github.com/aria2/aria2) is a command-line download utility that supports HTTP(S), FTP, SFTP and BitTorrent. [AriaNg](https://github.com/mayswind/AriaNg) and [webui-aria2](https://github.com/ziahamza/webui-aria2) are web interfaces making aria2 easier to use.

This project expands on my contributions to (and borrows from) [onisuly/docker-aria2-with-webui](https://github.com/onisuly/docker-aria2-with-webui) as well as being influenced by the excellent images provided by [Linuxserver.io](https://www.linuxserver.io/).

Features include: BitTorrent trackers updated daily, log retention and rotation, choice of web interface and [s6-overlay](https://github.com/just-containers/s6-overlay) to better manage multiple processes.

## [Docker Compose](https://docs.docker.com/compose/compose-file/compose-file-v3/)

```yaml
version "3.8"
services:
  aria2-with-webui:
    container_name: aria2-with-webui
    image: ghcr.io/pwatk/aria2-with-webui
    restart: unless-stopped
    ports:
      - 80:80
      - 6800:6800
      - 6881-6999:6881-6999             # optional
      - 6881-6999:6881-6999/udp         # optional
    volumes:
      - /path/to/downloads:/data
      - /path/to/config:/config         # optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - FILE_ALLOCATION=none            # optional
      - SECRET=rpc-secret               # optional
      - BT_TRACKER=false                # optional
      - BT_TRACKER_URL=http...          # optional
      - BT_SEEDING=false                # optional
      - RPC_CERT=/path/to/fullchain.pem # optional
      - RPC_KEY=/path/to/privkey.pem    # optional
      - IPV6=true                       # optional
```

## Version tags

| Tag(s) | Description |
| :----: | --- |
| `AriaNg` `latest` | Latest release from aria2 and AriaNg |
| `webui-aria2` | Latest release from aria2 and git commit from webui-aria2  | 	

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
| `PUID` | [UID](https://en.wikipedia.org/wiki/Passwd "A user identifier, often abbreviated to user ID or UID") of a user on host machine - Owner of files and directories inside volumes. **Default: 911** |
| `PGID` | [GID](https://en.wikipedia.org/wiki/Group_identifier "A group identifier, often abbreviated to GID") of group on host machine - Group assigned to files and directories inside volumes. **Default: 911** |
| `TZ` | Specify a [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to use e.g. Europe/London. **Default: undefined** |
| `FILE_ALLOCATION` | Sets the [file allocation](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-file-allocation "--file-allocation=<METHOD>") method. Available values: *none, prealloc, trunc or falloc*. **Default: undefined** |
| `SECRET` | Set [RPC secret](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-rpc-secret "--rpc-secret=<TOKEN>") authorization token (overridden by SECRET_FILE). **Default: undefined** |
| `SECRET_FILE` | Set [RPC secret](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-rpc-secret "--rpc-secret=<TOKEN>") authorization token using [Docker secrets](https://docs.docker.com/compose/compose-file/compose-file-v3/#secrets). e.g. /run/secrets/aria2-rpc-secret. **Default: undefined** |
| `BT_TRACKER` | Enable or disable daily automatic updates of [BitTorrent trackers](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-bt-tracker "--bt-tracker=<URI>[,...]"). Available values: *true or false*. **Default: true** |
| `BT_TRACKER_URL` | Specify a URL from which to download a BitTorrent trackers list (comma or newline seperated). **Default: [trackers_best.txt](https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt) from [ngosang/trackerslist](https://github.com/ngosang/trackerslist)**
| `BT_SEEDING` | Enable or disable [BitTorrent seeding](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-seed-time "--seed-time=0"). Available values: *true or false*. **Default: true** |
| `RPC_CERT` | [Location](https://docs.docker.com/storage/bind-mounts/) of [RPC certificate](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-rpc-certificate "--rpc-certificate=<FILE>"). It is recommended to use a reverse proxy to secure both Aria2 and AriaNg instead. A configuration file for [SWAG](https://github.com/linuxserver/docker-swag) can be found in the [proxy-confs folder](https://github.com/pwatk/docker-aria2-with-webui/tree/master/proxy-confs). **Default: undefined** |
| `RPC_KEY` | [Location](https://docs.docker.com/storage/bind-mounts/) of [RPC private key](https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-rpc-private-key "--rpc-private-key=<FILE>"). It is recommended to use a reverse proxy to secure both Aria2 and AriaNg instead. A configuration file for [SWAG](https://github.com/linuxserver/docker-swag) can be found in the [proxy-confs folder](https://github.com/pwatk/docker-aria2-with-webui/tree/master/proxy-confs). **Default: undefined** |
| `IPV6` | Enable or disable IPv6 support. Available values: *true or false*. **Default: false** |
