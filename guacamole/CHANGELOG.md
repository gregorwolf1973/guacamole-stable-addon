# Changelog

## 1.0.0 - 2026-04-28

### Initial release

- Apache Guacamole 1.5.5
- FreeRDP 2.11.7 from source (fixes ignore-cert bug present in Ubuntu 22.04 FreeRDP 2.6.1)
- guacamole-server 1.5.5 from source
- Tomcat 9.0.99
- PostgreSQL 14 embedded
- Home Assistant Ingress support
- Multi-architecture: aarch64, amd64

## 1.0.1 - 2026-04-28

### Fixed
- Build error: removed `libavresample-dev` (no longer in Ubuntu 22.04 since FFmpeg 5.0)
- Reduced FreeRDP build dependencies to minimum needed for guacd (no X11/Wayland frontends)
- FreeRDP now builds without X11/PulseAudio/ALSA/CUPS/FFmpeg — guacd does not need them

## 1.0.2 - 2026-04-28

### Fixed
- FreeRDP build now uses full feature set (X11, PulseAudio, ALSA, CUPS, FFmpeg, GSM, FAAD2)
- Previous minimal build sent malformed RDP packets (TLS Client Hello without preceding X.224 CR-TPDU)
- guacd's FreeRDP plugins (guac-common-svc, guacai, etc.) now installed into `/opt/freerdp/lib/freerdp2/` so FreeRDP can load them at runtime
