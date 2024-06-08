#!/usr/bin/env bash

if [ x"$@" = x"Shutdown" ]; then
	shutdown now
	exit 0
elif [ x"$@" = x"Restart" ]; then
	shutdown -r now
	exit 0
elif [ x"$@" = x"Hibernate" ]; then
	systemctl suspend
	exit 0
fi

echo "Shutdown"
echo "Restart"
echo "Hibernate"

echo -en "\0prompt\x1f Power menu: \n"
