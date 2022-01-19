FROM debian:11-slim
ARG VERSION=current

ENV DEBIAN_FRONTEND=noninteractive \
    VERSION=${VERSION} \
    JD_UID=1000 \
    JD_GID=1000 \
    JD_NOVNC_PORT=6080 \
    JD_VNC_PASSWORD=changeme \
    JD_VNC_PORT=5900 \
    JD_VNC_DISPLAY=:0 \
    JD_START_VERBOSE=0

# VNC:
#     tigervnc, novnc, websockify, openbox, xfonts-scalable
# Junglediskwg:
#     libfuse2, psmisc, libnotify4
RUN apt-get update \
    && apt-get install -y \
        gosu \
        curl \
        tigervnc-standalone-server \
        novnc \
        websockify \
        openbox \
        xfonts-scalable \
        fuse \
        libfuse2 \
        psmisc \
        libnotify4 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


COPY start.sh get-jungledisk.sh /usr/local/bin/

# Create groups
# Create user
# Permit fuse devices to be read by other users (user_allow_other)
# Create ~/.local/share to resolve gtk warnings about writing to 
#   recently-used.xbel
# Install jungledisk app
RUN groupadd -g "$JD_GID" "jungledisk" \
    && groupadd "fuse" \
    && useradd -u "$JD_UID" -g "jungledisk" -G "fuse" -ms "/bin/bash" "jungledisk" \
    && echo "user_allow_other" >> /etc/fuse.conf \
    && gosu jungledisk mkdir -p "/home/jungledisk/.local/share" \
    && get-jungledisk.sh

EXPOSE $JD_VNC_PORT $JD_NOVNC_PORT

ENTRYPOINT [ "start.sh" ]