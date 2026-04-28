ARG FREERDP_VERSION=2.11.7
ARG GUACAMOLE_VERSION=1.5.5

# =============================================================================
# Stage 1: Build FreeRDP 2.11 from source
# Full feature set so the protocol negotiation works correctly
# =============================================================================
FROM ubuntu:22.04 AS freerdp-builder

ARG FREERDP_VERSION

ENV DEBIAN_FRONTEND=noninteractive

# Full set of build deps that the official Ubuntu freerdp2 package uses.
# libavresample-dev is removed (no longer in 22.04 since FFmpeg 5).
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    ca-certificates \
    pkg-config \
    libssl-dev \
    libx11-dev \
    libxext-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxdamage-dev \
    libxv-dev \
    libxkbfile-dev \
    libasound2-dev \
    libcups2-dev \
    libxml2-dev \
    libxrandr-dev \
    libpulse-dev \
    libssh2-1-dev \
    libusb-1.0-0-dev \
    libudev-dev \
    libdbus-glib-1-dev \
    uuid-dev \
    libxtst-dev \
    libavutil-dev \
    libavcodec-dev \
    libswscale-dev \
    libswresample-dev \
    libfaad-dev \
    libgsm1-dev \
    libfreetype-dev \
    libfontconfig-dev \
    libxi-dev \
    libxfixes-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN curl -fsSL "https://github.com/FreeRDP/FreeRDP/archive/refs/tags/${FREERDP_VERSION}.tar.gz" -o freerdp.tar.gz \
    && tar -xzf freerdp.tar.gz \
    && rm freerdp.tar.gz \
    && mv "FreeRDP-${FREERDP_VERSION}" freerdp

WORKDIR /build/freerdp/build

# Standard FreeRDP build with all client channels enabled.
# Only disable server/proxy/sample components we don't need.
RUN cmake -GNinja \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX=/opt/freerdp \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DWITH_SERVER=OFF \
    -DWITH_SHADOW=OFF \
    -DWITH_PROXY=OFF \
    -DWITH_SAMPLE=OFF \
    -DWITH_X11=ON \
    -DWITH_WAYLAND=OFF \
    -DWITH_PULSE=ON \
    -DWITH_ALSA=ON \
    -DWITH_CUPS=ON \
    -DWITH_FFMPEG=ON \
    -DWITH_SWSCALE=ON \
    -DWITH_GSM=ON \
    -DWITH_FAAD2=ON \
    -DWITH_OPENH264=OFF \
    -DBUILD_TESTING=OFF \
    -DWITH_MANPAGES=OFF \
    -DCHANNEL_URBDRC=OFF \
    .. \
    && ninja \
    && ninja install

# =============================================================================
# Stage 2: Build guacamole-server (guacd) 1.5.5 from source against FreeRDP 2.11
# =============================================================================
FROM ubuntu:22.04 AS guacd-builder

ARG GUACAMOLE_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    automake \
    libtool \
    libtool-bin \
    pkg-config \
    curl \
    ca-certificates \
    libcairo2-dev \
    libjpeg-turbo8-dev \
    libpng-dev \
    libossp-uuid-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libpango1.0-dev \
    libssh2-1-dev \
    libtelnet-dev \
    libvncserver-dev \
    libwebsockets-dev \
    libpulse-dev \
    libssl-dev \
    libvorbis-dev \
    libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy FreeRDP from stage 1
COPY --from=freerdp-builder /opt/freerdp /opt/freerdp

# Make FreeRDP findable by pkg-config and the linker during build
ENV PKG_CONFIG_PATH=/opt/freerdp/lib/pkgconfig
ENV LD_LIBRARY_PATH=/opt/freerdp/lib

WORKDIR /build

RUN curl -fsSL "https://archive.apache.org/dist/guacamole/${GUACAMOLE_VERSION}/source/guacamole-server-${GUACAMOLE_VERSION}.tar.gz" -o guacd.tar.gz \
    && tar -xzf guacd.tar.gz \
    && rm guacd.tar.gz \
    && mv "guacamole-server-${GUACAMOLE_VERSION}" guacd

WORKDIR /build/guacd

# Important: install guac-common-svc and other FreeRDP plugins INTO the
# FreeRDP plugin directory so FreeRDP can load them at runtime.
RUN ./configure \
        --prefix=/opt/guacamole \
        --with-freerdp-plugin-dir=/opt/freerdp/lib/freerdp2 \
    && make -j"$(nproc)" \
    && make install

# =============================================================================
# Stage 3: Final runtime image
# =============================================================================
FROM ubuntu:22.04

ARG GUACAMOLE_VERSION

ENV DEBIAN_FRONTEND=noninteractive

# Runtime dependencies (all the libraries FreeRDP and guacd link against)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    postgresql-14 \
    postgresql-contrib-14 \
    curl \
    ca-certificates \
    netcat-openbsd \
    procps \
    sudo \
    jq \
    openssl \
    bash \
    libcairo2 \
    libjpeg-turbo8 \
    libpng16-16 \
    libossp-uuid16 \
    libavcodec58 \
    libavformat58 \
    libavutil56 \
    libswscale5 \
    libswresample3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libssh2-1 \
    libtelnet2 \
    libvncclient1 \
    libwebsockets16 \
    libpulse0 \
    libssl3 \
    libvorbis0a \
    libvorbisenc2 \
    libvorbisfile3 \
    libwebp7 \
    libx11-6 \
    libxext6 \
    libxinerama1 \
    libxcursor1 \
    libxdamage1 \
    libxv1 \
    libxkbfile1 \
    libxrandr2 \
    libxtst6 \
    libxi6 \
    libxfixes3 \
    libcups2 \
    libasound2 \
    libxml2 \
    libusb-1.0-0 \
    libudev1 \
    libdbus-glib-1-2 \
    libfaad2 \
    libgsm1 \
    libfreetype6 \
    libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*

# Copy FreeRDP 2.11 from stage 1 (includes plugin dir at /opt/freerdp/lib/freerdp2)
COPY --from=freerdp-builder /opt/freerdp /opt/freerdp

# Copy guacd from stage 2 (the freerdp plugins were installed into /opt/freerdp/lib/freerdp2)
COPY --from=guacd-builder /opt/guacamole /opt/guacamole
COPY --from=guacd-builder /opt/freerdp/lib/freerdp2 /opt/freerdp/lib/freerdp2

# Make libraries findable
RUN echo "/opt/freerdp/lib" > /etc/ld.so.conf.d/freerdp.conf \
    && echo "/opt/guacamole/lib" > /etc/ld.so.conf.d/guacamole.conf \
    && ldconfig

# Symlink guacd binary into PATH
RUN ln -s /opt/guacamole/sbin/guacd /usr/local/sbin/guacd

# Install Tomcat 9
ENV TOMCAT_VERSION=9.0.99
ENV CATALINA_HOME=/opt/tomcat
RUN curl -fsSL "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" -o /tmp/tomcat.tar.gz \
    && mkdir -p ${CATALINA_HOME} \
    && tar -xzf /tmp/tomcat.tar.gz -C ${CATALINA_HOME} --strip-components=1 \
    && rm /tmp/tomcat.tar.gz \
    && rm -rf ${CATALINA_HOME}/webapps/* \
    && rm -rf ${CATALINA_HOME}/temp/* \
    && useradd -r -d ${CATALINA_HOME} -s /bin/false tomcat \
    && chown -R tomcat:tomcat ${CATALINA_HOME}

# Download Guacamole webapp 1.5.5 WAR
RUN curl -fsSL "https://archive.apache.org/dist/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-${GUACAMOLE_VERSION}.war" \
        -o ${CATALINA_HOME}/webapps/ROOT.war \
    && chown tomcat:tomcat ${CATALINA_HOME}/webapps/ROOT.war

# Setup Guacamole config directory and JDBC auth extension
ENV GUACAMOLE_HOME=/etc/guacamole
RUN mkdir -p ${GUACAMOLE_HOME}/extensions ${GUACAMOLE_HOME}/lib /opt/guacamole-schema

RUN curl -fsSL "https://archive.apache.org/dist/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-auth-jdbc-${GUACAMOLE_VERSION}.tar.gz" \
        -o /tmp/jdbc.tar.gz \
    && mkdir -p /tmp/jdbc \
    && tar -xzf /tmp/jdbc.tar.gz -C /tmp/jdbc --strip-components=1 \
    && cp /tmp/jdbc/postgresql/guacamole-auth-jdbc-postgresql-*.jar ${GUACAMOLE_HOME}/extensions/ \
    && cp /tmp/jdbc/postgresql/schema/*.sql /opt/guacamole-schema/ \
    && rm -rf /tmp/jdbc /tmp/jdbc.tar.gz

# PostgreSQL JDBC driver
RUN curl -fsSL "https://jdbc.postgresql.org/download/postgresql-42.7.3.jar" \
        -o ${GUACAMOLE_HOME}/lib/postgresql-jdbc.jar

# TOTP (2FA) extension - bundled but only activated when totp_enabled=true
RUN mkdir -p /opt/guacamole-bundled \
    && curl -fsSL "https://archive.apache.org/dist/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-auth-totp-${GUACAMOLE_VERSION}.tar.gz" \
        -o /tmp/totp.tar.gz \
    && mkdir -p /tmp/totp \
    && tar -xzf /tmp/totp.tar.gz -C /tmp/totp --strip-components=1 \
    && cp /tmp/totp/guacamole-auth-totp-*.jar /opt/guacamole-bundled/ \
    && rm -rf /tmp/totp /tmp/totp.tar.gz

# guacd home directory (FreeRDP fix from GUACAMOLE-2092)
RUN mkdir -p /var/lib/guacd && chown daemon:daemon /var/lib/guacd

# PostgreSQL data location (will be persisted in /data)
ENV PGDATA=/data/postgres

# Copy startup script
COPY rootfs/ /
RUN chmod +x /usr/local/bin/run.sh

EXPOSE 8080

CMD ["/usr/local/bin/run.sh"]
