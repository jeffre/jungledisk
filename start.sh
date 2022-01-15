#!/bin/sh

if [ "$JD_START_VERBOSE" = 1 ]; then
  set -x
fi


# Check for changes to UID/GID
if [ "$JD_UID" != $(id -u jungledisk) ]; then
  usermod -o -u "$JD_UID" jungledisk
fi
if [ "$JD_GID" != $(id -g jungledisk) ]; then
  groupmod -o -g "$JD_GID" jungledisk
fi


# For convienence, create a single directory (/jungledisk) that will house
# configuration files that can be used as a docker VOLUME.
mkdir -p "/jungledisk/conf"
ln -sf "/jungledisk/conf" "/home/jungledisk/.jungledisk"
chown jungledisk:jungledisk "/jungledisk/conf" "/home/jungledisk/.jungledisk"


# [vnc] create config directory
vncconf="/home/jungledisk/.vnc"
mkdir -p "$vncconf"
chown jungledisk:jungledisk "$vncconf"

# [vnc] set password
echo "$JD_VNC_PASSWORD" | tigervncpasswd -f > "$vncconf/passwd"
chmod 600 "$vncconf/passwd"
chown jungledisk:jungledisk "$vncconf/passwd"

# [vnc] Cleanup previous session data
gosu jungledisk tigervncserver -kill "$JD_VNC_DISPLAY"

# [vnc] Export display variable
export DISPLAY="$JD_VNC_DISPLAY"

# [vnc] Start VNC
gosu jungledisk tigervncserver -SecurityTypes VncAuth,TLSVnc "$JD_VNC_DISPLAY"


# [noVNC] Self-signed ssl certificate
novnccert="$vncconf/novnc.pem"

# [noVNC] Delete expired certificate
if [ -f "$novnccert" ]; then
  if [ openssl x509 -noout -in "$novnccert" -checkend 0 > /dev/null ]; then
    echo "noVNC SSL certificate has expired; generating a new certificate now."
    rm "$novnccert"
  fi
fi

# [noVNC] Generate self-signed certificate
if [ ! -f "$novnccert" ]; then
  openssl req -x509 -nodes -newkey rsa:2048 -keyout "$novnccert" -out "$novnccert" -days 365 -subj "/CN=jungledisk"
fi

# [noVNC] Take exclusive ownership of certificate
chown jungledisk:jungledisk "$novnccert"
chmod 600 "$novnccert"

# [noVNC] Background daemonize noVNC startup
gosu jungledisk websockify -D --web=/usr/share/novnc/ --cert="$novnccert" "$JD_NOVNC_PORT" "localhost:$JD_VNC_PORT"


# [jungledisk] Foreground start jungledisk app
exec gosu jungledisk /usr/local/bin/jungledisk