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

## 1.0.3 - 2026-04-28

### Added
- TOTP (2FA) support via guacamole-auth-totp extension
- New option `totp_enabled` (true/false) in Add-on configuration
- When enabled: users must enroll their TOTP app (Google Authenticator, Aegis, etc.) on first login

## 1.0.4 - 2026-04-28

### Fixed
- TOTP extension is now properly enabled/disabled based on `totp_enabled` option
- Previously the JAR was always loaded regardless of the config setting, locking out users when disabled
- TOTP JAR is now bundled in `/opt/guacamole-bundled/` and copied to active extensions folder only when enabled
- When `totp_enabled` is set to `false`, all `guac-totp-*` user attributes are cleaned from the database, allowing password-only login

## 1.0.5 - 2026-09-12

### Changed
- FreeRDP 2.11.7 → 2.11.8 (letztes 2.x-Release, nur Bugfix-Backports)
- Tomcat 9.0.99 → 9.0.121
- PostgreSQL JDBC-Treiber 42.7.3 → 42.7.13 (enthält u. a. den SCRAM-Channel-Binding-Fix)

### Fixed
- Sauberes Herunterfahren: Tomcat wurde per `exec` gestartet, wodurch der SIGTERM-Handler nie lief und guacd/PostgreSQL beim Stoppen des Add-ons hart beendet wurden. Tomcat läuft jetzt als überwachter Kindprozess, beim Stop werden Tomcat, guacd und PostgreSQL geordnet beendet.
- Beendet sich Tomcat von selbst, werden guacd und PostgreSQL ebenfalls gestoppt statt weiterzulaufen.
- Besitzer/Rechte von `/data/postgres` werden bei jedem Start korrigiert (z. B. nach einer Backup-Wiederherstellung).
- `.gitattributes`: `run.sh` wird immer mit LF-Zeilenenden ausgecheckt.

### Docs
- README: Option `totp_enabled` dokumentiert.

## 1.0.6 - 2026-09-13

### Fixed
- Build repariert. FreeRDP 2.11.8 wird von guacd abgelehnt: dessen configure
  erkennt die Quelle als Entwicklungsversion und bricht mit
  "PLEASE USE A RELEASED VERSION OF FREERDP" ab. FreeRDP bleibt daher bei
  2.11.7. Die Updates von Tomcat (9.0.121) und PostgreSQL-JDBC (42.7.13)
  sowie das saubere Herunterfahren aus 1.0.5 bleiben erhalten.
