#!/bin/bash

#
# generate XAUTHORITY file for use with docker containers
#

sudo rm -fr /tmp/.docker.xauth

xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f /tmp/.docker.xauth nmerge - 2>/dev/null 
