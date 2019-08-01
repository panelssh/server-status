#!/bin/bash

# Parametet
# 1 : IP Addres Master
# 2 : Username Client
# 3 : Password Client
# 4 : Server ID
# 5 : Nameserver Client
# 6 : Hostname Client
# 7 : Location Client

if [ "$1" == "" ]; then
    echo -e "\033[0;31mYou Must Put IP Address Master Server!\033[0m"
    exit 1
fi

if [ "$2" == "" ]; then
    echo -e "\033[0;31mYou Must Put Username!\033[0m"
    exit 1
fi

if [ "$3" == "" ]; then
    echo -e "\033[0;31mYou Must Put Password!\033[0m"
    exit 1
fi

if [ "$4" == "" ]; then
    _SERVER_ID="not configured!"
else
    _SERVER_ID="$4"
fi

if [ "$5" == "" ]; then
    _NAMESERVER="not configured!"
else
    _NAMESERVER="$5"
fi

if [ "$6" == "" ]; then
    _HOSTNAME="not configured!"
else
    _HOSTNAME="$6"
fi

if [ "$7" == "" ]; then
    _LOCATION="not configured!"
else
    _LOCATION="$7"
fi

PYTHON_CLIENT="https://raw.githubusercontent.com/panelssh/server-status/master/client/client.py"

CWD=$(pwd)

command_exists () {
    type "$1" &> /dev/null ;
}

if ! command_exists curl; then
    echo "curl not found, install it."
    exit 1
fi

CLIENT="python"

#cek file serverclient.py

if [ -f "${CWD}/serverclient.py" ]; then
    CLIENT_BIN="${CWD}/serverclient.py"
    SKIP=true
fi

if [ ! $SKIP ]; then
    SERVER="$1"
    USERNAME="$2"
    PASSWORD="$3"
    PORT=35600
else
    DATA=$(head -n 9 "$CLIENT_BIN")
    SERVER=$(echo "$DATA" | sed -n "s/SERVER\( \|\)=\( \|\)//p" | tr -d '"')
    PORT=$(echo "$DATA" | sed -n "s/PORT\( \|\)=\( \|\)//p" | tr -d '"')
    USERNAME=$(echo "$DATA" | sed -n "s/USER\( \|\)=\( \|\)//p" | tr -d '"')
    PASSWORD=$(echo "$DATA" | sed -n "s/PASSWORD\( \|\)=\( \|\)//p" | tr -d '"')
fi

curl -L "$PYTHON_CLIENT" | sed -e "0,/^SERVER = .*$/s//SERVER = \"${SERVER}\"/" \
-e "0,/^PORT = .*$/s//PORT = ${PORT}/" \
-e "0,/^USER = .*$/s//USER = \"${USERNAME}\"/" \
-e "0,/^PASSWORD = .*$/s//PASSWORD = \"${PASSWORD}\"/" > "${CWD}/serverclient.py"
chmod +x "${CWD}/serverclient.py"
CLIENT_BIN="${CWD}/serverclient.py"

INIT="sysvinit"

_CLIENT=$(echo "$CLIENT_BIN" | sed "s|$CWD|/usr/local/share|g")
sudo cp -a "$CLIENT_BIN" "$_CLIENT"

# Install service
if [ "$INIT" == "sysvinit" ]; then
    RUNUSER="www-data"
    if ! id -u "$RUNUSER" >/dev/null 2>&1; then
        echo "The specified user \"$RUNUSER\" could not be found!"
        exit 1
    fi
    if [ -f /etc/init.d/serverclient ]; then
        REPLACE=true
    fi
    
	sudo tee "/etc/init.d/serverclient" > /dev/null <<__EOF__
#!/bin/sh
### BEGIN INIT INFO
# Provides:          serverclient
# Required-Start:    \$remote_fs \$network
# Required-Stop:     \$remote_fs \$network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Server Status Client
# Description:       Server Status Client
### END INIT INFO

. /lib/lsb/init-functions

DAEMON="$_CLIENT"
RUNAS="$RUNUSER"
DESC="Server Status Client"

PIDFILE=/var/run/serverclient.pid

test -x "\$DAEMON" || exit 5

case \$1 in
	start)
		log_daemon_msg "Starting \$DESC"
		start-stop-daemon --start --background --pidfile "\$PIDFILE" --make-pidfile --chuid "\$RUNAS" --startas "\$DAEMON"

		if [ \$? -ne 0 ]; then
			log_end_msg 1
		else
			log_end_msg 0
		fi
		;;
	stop)
		log_daemon_msg "Stopping \$DESC"
		start-stop-daemon --stop --pidfile "\$PIDFILE" --retry 5

		if [ \$? -ne 0 ]; then
			log_end_msg 1
		else
			log_end_msg 0
		fi
		;;
	restart)
		\$0 stop
		sleep 1
		\$0 start
		;;
	status)
		status_of_proc -p "\$PIDFILE" "\$DAEMON" "serverclient" && exit 0 || exit \$?
		;;
	*)
		echo "Usage: \$0 {start|stop|restart|status}"
		exit 2
		;;
esac
__EOF__
    
    sudo chown "$RUNUSER" "$_CLIENT"
    sudo chmod +x /etc/init.d/serverclient
    if [ $REPLACE ]; then
        sudo service serverclient stop
        sleep 1
    fi
    sudo service serverclient start
    sleep 1
    sudo service serverclient status
    sleep 1
    sudo update-rc.d serverclient defaults
    sudo update-rc.d serverclient enable
fi

if [ ! $SKIP ]; then
    echo
    echo "Copy this and paste this config to Master Server Status:"
    echo
    echo -e "\t\t{"
    echo -e "\t\t\t\"server_id\": \"$_SERVER_ID\","
    echo -e "\t\t\t\"nameserver\": \"$_NAMESERVER\","
    echo -e "\t\t\t\"hostname\": \"$_HOSTNAME\","
    echo -e "\t\t\t\"location\": \"$_LOCATION\","
    echo -e "\t\t\t\"username\": \"$USERNAME\","
    echo -e "\t\t\t\"password\": \"$PASSWORD\","
    echo -e "\t\t\t\"custom\": \"\""
    echo -e "\t\t},"
fi

exit 0
