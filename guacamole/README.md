# Guacamole Stable

Apache Guacamole 1.5.5 als Home Assistant Add-on mit selbst kompilierter **FreeRDP 2.11** – behebt RDP-Verbindungsprobleme zu xrdp-Servern.

## Warum dieses Addon?

Die offizielle Version 1.6.0 sowie das beliebte alexbelgium-Addon haben Bugs:

- **GUACAMOLE-2092**: FreeRDP-Initialisierung scheitert wegen fehlendem Home-Verzeichnis
- **FreeRDP 2.6.1** (Ubuntu 22.04 Standard-Paket): `ignore-cert` Option wird nicht respektiert; Verbindungen zu xrdp-Servern enden mit "SSL/TLS connection failed"

Dieses Addon kompiliert FreeRDP **2.11.7** und guacamole-server **1.5.5** komplett aus dem Source-Code.

## Features

- Apache Guacamole 1.5.5 Web-Client (HTML5)
- guacd 1.5.5, gegen FreeRDP 2.11 gelinkt
- Tomcat 9 + PostgreSQL 14 embedded
- Home Assistant Ingress: Zugriff direkt aus der HA Sidebar
- Persistente Daten in `/data/postgres`
- ARM64 (Raspberry Pi 5) und AMD64

## Installation

1. **Settings → Add-ons → Add-on Store → ⋮ → Repositories**
2. Repository-URL hinzufügen:
   ```
   https://github.com/gregorwolf1973/guacamole-stable-addon
   ```
3. **Guacamole Stable** installieren und starten
4. Web-UI: über Sidebar oder Port 8080
5. Login: `guacadmin` / das in den Optionen gesetzte Passwort

## Konfiguration

```yaml
log_level: info           # trace, debug, info, warning, error
guacadmin_password: ...   # nur beim ersten Start angewendet
```

Das `guacadmin_password` wird nur bei der **Erstinitialisierung** angewendet (DB-Erstellung). Danach kannst du es über die Web-UI ändern.

## Verbindung zu Linux/xrdp einrichten

| Feld | Wert |
|---|---|
| Protokoll | RDP |
| Hostname | IP des Linux-Rechners |
| Port | 3389 |
| Sicherheitsmodus | `Any` |
| Serverzertifikat ignorieren | ✅ |
| Benutzername | (Linux-User) |
| Passwort | (Linux-Passwort) |

## Verbindung zu Windows einrichten

| Feld | Wert |
|---|---|
| Protokoll | RDP |
| Hostname | IP/Hostname des Windows-Rechners |
| Port | 3389 |
| Sicherheitsmodus | `NLA` |
| Serverzertifikat ignorieren | ✅ |
| Benutzername | (Windows-User) |
| Passwort | (Windows-Passwort) |

## Daten-Persistenz

Alle Daten (Verbindungen, Nutzer, Settings) liegen in PostgreSQL unter `/data/postgres` und überleben Add-on-Restarts und Updates.

## Lizenz

Apache 2.0
