#
# darktable-alpine built from source
# osm-gps-map and pugixml are built from sources
# 
# image size: 186.2MB
# 
# Build command:
#     docker build -t darktable-alpine:2.4.0 --build-arg UID=$(id -u ${USER}) --build-arg GID=$(id -g ${USER}) --build-arg DARKTABLE_TAG=2.4.0 .
#
# Start container:
#     docker run -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix 
#                         -v /tmp/.docker.xauth:/tmp/.docker.xauth 
#                         -e XAUTHORITY=/tmp/.docker.xauth
#                         -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id
#                         -v /mnt/host/photos:/home/darktable/picures

FROM alpine:3.8

ARG PUID=1000
ARG PGID=1000
ARG DARKTABLE_TAG=release-2.4.4

RUN set -eux \
    && apk --no-cache update \
    && apk --no-cache add \
        adwaita-icon-theme \
        busybox-suid \
        curl \
        exiv2 \
        gtk+3.0 \
        json-glib \
        lcms2 \
        lensfun \
        libgomp \
        libgphoto2 \
        librsvg \
        libsoup \
        libwebp \
        mesa-gl \
        openexr \
        openjpeg \
        ttf-dejavu \
    && apk --no-cache --virtual .build-deps add \
        autoconf \
        automake \
        binutils \
        build-base \
        cmake \
        coreutils \
        curl-dev \
        exiv2-dev \
        gcc \
        git \
        glib-dev \
        gnome-common \
        gobject-introspection-dev \
        gtk+3.0-dev \
        gtk-doc \
        intltool \
        json-glib-dev \
        lcms2-dev \
        lensfun-dev \
        libjpeg-turbo-dev \
        libgphoto2-dev \
        librsvg-dev \
        libsoup-dev \
        libtool \
        libwebp-dev \
        libxml2-dev \
        libxslt \
        openexr-dev \
        openjpeg-dev \
        sqlite-dev \
        tiff-dev \
# compile and install osm-gps-map
    && mkdir -p /tmp/osmgpsmap && cd /tmp/osmgpsmap \
    && git clone http://github.com/nzjrs/osm-gps-map \
    && cd osm-gps-map && ./autogen.sh \
    && make && make install \
# compile and install pugixml
    && mkdir -p /tmp/build-pugi && cd /tmp/build-pugi \
    && git clone https://github.com/zeux/pugixml.git \
    && cmake ./pugixml -DCMAKE_BUILD_TYPE=Release \
                       -DCMAKE_INSTALL_PREFIX=/usr \
                       -DCMAKE_INSTALL_LIBDIR=lib \
                       -DBUILD_SHARED_LIBS=ON \
    && make && make install \
# configure and compile darktable
    && mkdir -p /tmp/build && cd /tmp/build \
    && git clone --depth 1 --branch ${DARKTABLE_TAG} https://github.com/darktable-org/darktable.git \
    && cd darktable \
    && git submodule update --init \
    && ./build.sh \
# install darktable
    && cmake --build "/tmp/build/darktable/build" --target install -- -j2 \
# cleanup
    && rm -frv /tmp/* \
    && apk del .build-deps \
# set up work environment
    && addgroup -g ${PGID} darktable \
    && adduser -h /home/darktable -u ${PUID} -s /bin/ash -D -G darktable darktable \
    && mkdir -p /home/darktable/pictures /home/darktable/.config/darktable /var/lib/dbus \
    && echo "0123456789abcdef0123456789abcdef" > /var/lib/dbus/machine-id \
    && chown ${PUID}:${PGID} -R /home/darktable \
    && echo "export PATH=$PATH:/opt/darktable/bin" >> /etc/profile \
    && echo "export PICTURES_FOLDER=/home/darktable/pictures" >> /etc/profile

WORKDIR /home/darktable
USER darktable

VOLUME ["/home/darktable/.config/darktable", "/home/darktable/pictures"]

CMD ["/opt/darktable/bin/darktable"]
