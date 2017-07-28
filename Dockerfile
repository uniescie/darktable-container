#
# darktable 2.2.5 built from source
# osm-gps-map and pugixml are built from sources
# 
# image size: 159.4 MB
# 
# Build command:
#     docker build -t darktable --build-arg UID=$(id -g ${USER}) .
#
# Start container:
#     docker run -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix 
#                         -v /tmp/.docker.xauth:/tmp/.docker.xauth 
#                         -e XAUTHORITY=/tmp/.docker.xauth
#                         -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id
#                         -v /mnt/host/photos:/home/darktable/picures

# need to use alpine3.5 for openexr and gnome-common
FROM alpine:3.5

ARG UID=1000

RUN apk update \
    && apk add busybox-suid \
               build-base \
               gcc \
               binutils \
               cmake \
               glib-dev \
               gtk+3.0 \
               gtk+3.0-dev \
               libxml2-dev \
               intltool \
               libxslt \
               libgphoto2 \
               libgphoto2-dev \
               lensfun \
               lensfun-dev \
               librsvg \
               librsvg-dev \
               sqlite-dev \
               curl \
               curl-dev \
               libjpeg-turbo-dev \
               tiff-dev \
               lcms2 \
               lcms2-dev \
               json-glib \
               json-glib-dev \
               exiv2 \
               exiv2-dev \
               libwebp \
               libwebp-dev \
               openjpeg \
               openjpeg-dev \
               libsoup \
               libsoup-dev \
               libtool \
               gtk-doc \
               autoconf \
               automake \
               coreutils \
               gobject-introspection-dev \
               git \
               gnome-common \
               openexr \
               openexr-dev \
               libgomp \
               ttf-dejavu \
               adwaita-icon-theme \
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
    && mkdir -p /tmp/build-dt && cd /tmp/build-dt \
    && git clone --branch release-2.2.5 https://github.com/darktable-org/darktable.git \
    && cd darktable && ./build.sh \
    && (>&2 echo -e "\nInstalling darktable ...\n") \
    && cmake --build "/tmp/build-dt/darktable/build" --target install -- -j2 \
    && (>&2 echo -e "\nCleaning up ...\n") \
    && rm -frv /tmp/osmgpsmap /tmp/build-pugi /tmp/build-dt \
    && apk del build-base \
               gcc \
               binutils \
               cmake \
               glib-dev \
               gtk+3.0-dev \
               libxml2-dev \
               intltool \
               libxslt \
               libgphoto2-dev \
               lensfun-dev \
               librsvg-dev \
               sqlite-dev \
               curl-dev \
               libjpeg-turbo-dev \
               tiff-dev \
               lcms2-dev \
               json-glib-dev \
               exiv2-dev \
               libwebp-dev \
               openjpeg-dev \
               libsoup-dev \
               libtool \
               gtk-doc \
               autoconf \
               automake \
               coreutils \
               gobject-introspection-dev \
               git \
               gnome-common \
               openexr-dev \
    && (>&2 echo "Setting up work environment ...") \
    && addgroup -g ${UID} darktable \
    && adduser -h /home/darktable -u ${UID} -s /bin/sh -D -G darktable darktable \
    && echo 'darktable:darktable' | chpasswd \
    && echo 'root:123456' | chpasswd \
    && mkdir -p /home/darktable/pictures \
    && chown darktable:darktable -R /home/darktable \
    && echo "alias ll='ls -alh --color'" >> /etc/profile \
    && echo "export PATH=$PATH:/opt/darktable/bin" >> /etc/profile \
    && echo "export PICTURES_FOLDER=/home/darktable/pictures" >> /etc/profile \
    && mv /etc/profile.d/color_prompt /etc/profile.d/color_prompt.sh

WORKDIR /home/darktable
USER darktable

CMD ["/opt/darktable/bin/darktable"]
