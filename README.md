# Ubuntu 26.10 VNC Desktop

Ubuntu 26.10 + LXDE desktop + VNC/noVNC, accessible via browser.

## Quick Start

```bash
docker run -d \
  -p 6080:6080 \
  -p 5901:5901 \
  -e VNC_PASSWORD=mypassword \
  --name ubuntu-vnc \
  ghcr.io/yizhixiaoliulang/ubuntu26_vnc_docker:latest
```

Open browser: `http://localhost:6080/vnc.html`, enter VNC password to connect.

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `VNC_PASSWORD` | `ubuntu26` | VNC connection password (also set as root password) |
| `VNC_RESOLUTION` | `1920x1080` | Desktop resolution |
| `VNC_COL_DEPTH` | `24` | Color depth |

## Ports

| Port | Service |
|---|---|
| 5901 | VNC server |
| 6080 | noVNC web client |

## SSH Access

Root password is the same as `VNC_PASSWORD`. If you expose port 22, you can SSH in directly.

## Build Locally

```bash
docker build -t ubuntu-vnc .
docker run -d -p 6080:6080 -e VNC_PASSWORD=test ubuntu-vnc
```

## License

MIT
