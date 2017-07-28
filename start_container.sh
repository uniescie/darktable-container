#!/usr/bin/env bash

# connect X server socket
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f ${XAUTH} nmerge -
X_OPTS="-v ${XSOCK}:${XSOCK} -v ${XAUTH}:${XAUTH} -e XAUTHORITY=${XAUTH} -e DISPLAY"

DIR_OPTS="-v /mnt/host/pictures:/home/darktable/pictures"

DBUS_OPTS="-v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id"

# DEBUG_OPTS=""

cmd="docker run -it --rm ${DIR_OPTS}
                         ${X_OPTS}
                         ${DBUS_OPTS}
                         ${DEBUG_OPTS}
                         --name darktable
                         darktable"

echo -e "\nStarting darktable container..."
echo ${cmd}
${cmd}
