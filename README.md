# Server Status - Panel SSH

![](https://github.com/panelssh/server-status/workflows/build/badge.svg)

This repository is a rewrite of  [BotoX](https://github.com/BotoX) [ServerStatus](https://github.com/BotoX/ServerStatus) script.

## Installation

### Master Server

```bash
apt-get update && apt-get -y upgrade && apt-get -y install curl nano apache2 git make build-essential
```

```bash
git clone https://github.com/panelssh/server-status.git
cd server-status/server
make
./servermaster
```

`CTRL + C` or `CMD + C`

```bash
cp -r ~/server-status/status /var/www/html
chmod -R +x /var/www/html/status
cp -r ~/server-status/other/servermaster.initd /etc/init.d/servermaster
chmod +x /etc/init.d/servermaster
```

#### Configure

```bash
nano /etc/init.d/servermaster

# Change this according to your setup!
DAEMON_PATH="/root/server-status/server"
WEB_PATH="/var/www/html/status"
DAEMON="servermaster"
OPTS="-d $WEB_PATH"
RUNAS="www-data"

# Auto Start
update-rc.d servermaster defaults
update-rc.d servermaster enable
```

### Client Server

```bash
cd ~/
wget https://raw.github.com/panelssh/server-status/master/other/client-setup.sh
bash client-setup.sh IP_MASTER_SERVER USERNAME PASSWORD
```

---

## Client List

Simply edit the config.json file, it's self explanatory.

```bash
nano /root/server-status/server/config.json
```

```json
{
 "servers": [
   {
    "server_id": "your_server_id",
    "nameserver": "your_nameserver",
    "hostname": "your_hostname",
    "location": "your_location",
    "username": "client_username",
    "password": "client_password",
    "custom": ""
   }
 ]
}
```

If you want to temporarily disable a server you can add

```json
"disabled": true
```

### Restart Service

```bash
/etc/init.d/servermaster restart
```

---

## Uninstall

```bash
# Master Server
cd ~/
/etc/init.d/servermaster stop
rm -f /etc/init.d/servermaster
rm -r /root/server-status

#Client Server
cd ~/
/etc/init.d/serverclient stop
rm -f client-setup.sh
rm -f serverclient.py
rm -f /usr/local/share/serverclient
rm -f /etc/init.d/serverclient
```

---

## Other Command

```bash
# Master Server
update-rc.d servermaster defaults
update-rc.d servermaster enable
update-rc.d servermaster disable
update-rc.d servermaster remove

/etc/init.d/servermaster start
/etc/init.d/servermaster stop
/etc/init.d/servermaster restart
/etc/init.d/servermaster status

# Client Server
update-rc.d serverclient defaults
update-rc.d serverclient enable
update-rc.d serverclient disable
update-rc.d serverclient remove

/etc/init.d/serverclient start
/etc/init.d/serverclient stop
/etc/init.d/serverclient restart
/etc/init.d/serverclient status
```
