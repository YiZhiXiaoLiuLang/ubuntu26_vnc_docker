#!/bin/bash
set -e

echo "============================================"
echo " Ubuntu 26.10 VNC Desktop"
echo "============================================"

# ---- Set VNC password ----
mkdir -p ~/.vnc
x11vnc -storepasswd "${VNC_PASSWORD}" ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# ---- Set root password (same as VNC password) ----
echo "root:${VNC_PASSWORD}" | chpasswd
echo "[✓] Root password set (same as VNC password)"

# ---- Clean up stale locks / PIDs from previous runs ----
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true
rm -rf ~/.vnc/*.pid ~/.vnc/*.log 2>/dev/null || true

# ---- Disable lxpolkit to avoid "No session for PID" popup ----
mkdir -p ~/.config/lxsession/LXDE/
if [ -f /etc/xdg/lxsession/LXDE/desktop.conf ]; then
    cp /etc/xdg/lxsession/LXDE/desktop.conf ~/.config/lxsession/LXDE/desktop.conf
fi
if [ -f ~/.config/lxsession/LXDE/desktop.conf ]; then
    sed -i 's|^polkit/command=.*|polkit/command=|' ~/.config/lxsession/LXDE/desktop.conf
fi

# ---- Start D-Bus (required by LXDE) ----
if [ -d /run/dbus ]; then
    rm -f /run/dbus/pid
fi
dbus-daemon --system --fork 2>/dev/null || true
echo "[✓] D-Bus started"

# ---- Start PulseAudio (non-fatal if it fails) ----
pulseaudio --start --exit-idle-time=-1 2>/dev/null || true

# ---- Start Xvfb virtual display ----
Xvfb ${DISPLAY} -screen 0 ${VNC_RESOLUTION}x${VNC_COL_DEPTH} -ac +extension GLX +render -noreset &
sleep 1
echo "[✓] Xvfb started on ${DISPLAY} (${VNC_RESOLUTION})"

# ---- Start LXDE desktop environment ----
export XDG_SESSION_TYPE=x11
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p ${XDG_RUNTIME_DIR}
chmod 700 ${XDG_RUNTIME_DIR}

startlxde &
sleep 2
echo "[✓] LXDE desktop started"

# ---- Start VNC server (x11vnc) ----
x11vnc -display ${DISPLAY} \
    -forever \
    -shared \
    -rfbport 5901 \
    -rfbauth ~/.vnc/passwd \
    -noxdamage \
    -noxfixes \
    -noxrandr \
    -bg \
    -o ~/.vnc/x11vnc.log

echo "[✓] VNC server started on port 5901"

# ---- Start noVNC (web-based VNC client) ----
/usr/share/novnc/utils/novnc_proxy \
    --vnc localhost:5901 \
    --listen 6080 \
    --web /usr/share/novnc &
sleep 1

echo "[✓] noVNC web client started on port 6080"
echo ""
echo "============================================"
echo " Connection Info"
echo "============================================"
echo " VNC  : connect to port 5901"
echo " Web  : http://localhost:6080/vnc.html"
echo " Pass : (set via VNC_PASSWORD env)"
echo "============================================"

# ---- Keep the container running ----
# Wait for any child process to exit; if all die, tail the log
wait -n 2>/dev/null || true
tail -f ~/.vnc/x11vnc.log 2>/dev/null || tail -f /dev/null
