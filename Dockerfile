#
# darktable-alpine built from source
# osm-gps-map and pugixml are built from sources
# 
# image size: 160.7 MB
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

# need to use alpine3.5 for openexr and gnome-common
FROM alpine:3.5

ARG PUID=1000
ARG PGID=1000
ARG DARKTABLE_TAG=release-2.4.3

RUN apk --update --no-cache add \
        adwaita-icon-theme \
        autoconf \
        automake \
        binutils \
        build-base \
        busybox-suid \
        cmake \
        coreutils \
        curl \
        curl-dev \
        exiv2 \
        exiv2-dev \
        gcc \
        git \
        glib-dev \
        gnome-common \
        gobject-introspection-dev \
        gtk+3.0 \
        gtk+3.0-dev \
        gtk-doc \
        intltool \
        json-glib \
        json-glib-dev \
        lcms2 \
        lcms2-dev \
        lensfun \
        lensfun-dev \
        libjpeg-turbo-dev \
        libgomp \
        libgphoto2 \
        libgphoto2-dev \
        librsvg \
        librsvg-dev \
        libsoup \
        libsoup-dev \
        libtool \
        libwebp \
        libwebp-dev \
        libxml2-dev \
        libxslt \
        mesa-gl \
        openexr \
        openexr-dev \
        openjpeg \
        openjpeg-dev \
        sqlite-dev \
        tiff-dev \
        ttf-dejavu \
    && (>&2 echo -e "\nCompiling and installing osm-gps-map ...\n") \
    && mkdir -p /tmp/osmgpsmap && cd /tmp/osmgpsmap \
    && git clone http://github.com/nzjrs/osm-gps-map \
    && cd osm-gps-map && ./autogen.sh \
    && make && make install \
    && (>&2 echo -e "\nCompiling and installing pugixml ...\n") \
    && mkdir -p /tmp/build-pugi && cd /tmp/build-pugi \
    && git clone https://github.com/zeux/pugixml.git \
    && cmake ./pugixml -DCMAKE_BUILD_TYPE=Release \
                       -DCMAKE_INSTALL_PREFIX=/usr \
                       -DCMAKE_INSTALL_LIBDIR=lib \
                       -DBUILD_SHARED_LIBS=ON \
    && make && make install \
    && (>&2 echo -e "\nConfiguring and compiling darktable ...\n") \
    && mkdir -p /tmp/build && cd /tmp/build \
    && git clone --branch ${DARKTABLE_TAG} https://github.com/darktable-org/darktable.git \
    && cd darktable \
    && git submodule update --init \
    && ./build.sh \
    && (>&2 echo -e "\nInstalling darktable ...\n") \
    && cmake --build "/tmp/build/darktable/build" --target install -- -j2 \
    && (>&2 echo -e "\nCleaning up ...\n") \
    && cd / && rm -frv /tmp/* \
    && apk del \
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
            openjpeg-dev \
            openexr-dev \
            sqlite-dev \
            tiff-dev \
    && (>&2 echo "Setting up work environment ...") \
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
