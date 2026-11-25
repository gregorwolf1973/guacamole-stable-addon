# Guacamole Stable

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/gregorwolf1973) [![Donate using Liberapay](https://liberapay.com/assets/widgets/donate.svg)](https://liberapay.com/Gregor_Wolf/donate)

Apache Guacamole 1.5.5 als Home Assistant Add-on mit selbst kompilierter **FreeRDP 2.11** – behebt RDP-Verbindungsprobleme zu xrdp-Servern.

Dieses Addon kompiliert FreeRDP **2.11.7** und guacamole-server **1.5.5** komplett aus dem Source-Code.

## Features

- Apache Guacamole 1.5.5 Web-Client (HTML5)
- guacd 1.5.5, gegen FreeRDP 2.11 gelinkt
- Tomcat 9 + PostgreSQL 14 embedded
- Optional: Zwei-Faktor-Authentifizierung (TOTP)
- Home Assistant Ingress: Zugriff direkt aus der HA Sidebar
- Persistente Daten in `/data/postgres`
- ARM64 (Raspberry Pi 5) und AMD64

## Installation

1. **Einstellungen → Apps → App installieren → ⋮ → Repositories**
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
totp_enabled: false       # Zwei-Faktor-Authentifizierung (TOTP) aktivieren
ingress_ohne_anmeldung: true  # Seitenleiste meldet automatisch als guacadmin an
```

Das `guacadmin_password` wird nur bei der **Erstinitialisierung** angewendet (DB-Erstellung). Danach kannst du es über die Web-UI ändern.

Mit `totp_enabled: true` wird die Guacamole-TOTP-Erweiterung aktiviert: Jeder Benutzer muss beim nächsten Login eine Authenticator-App (Google Authenticator, Aegis, …) registrieren. Wird die Option wieder auf `false` gesetzt, werden die TOTP-Registrierungen aller Benutzer gelöscht und der Login funktioniert wieder nur mit Passwort.

### Automatische Anmeldung über die Seitenleiste (`ingress_ohne_anmeldung`)

Vorgabe `true`: Wer Guacamole über die HA-Seitenleiste (Ingress) öffnet, ist automatisch als `guacadmin` angemeldet. Der direkte Zugang über Port 8080 (z. B. über Reverse-Proxy/Cloudflare) verlangt weiterhin die normale Anmeldung. Technik: nginx im Container, Port 8099 (Ingress, nur vom HA-Supervisor erreichbar) setzt einen Anmelde-Header, Port 8080 löscht ihn; dazu die offizielle Erweiterung `guacamole-auth-header`.

**Risiko:** Jeder, der in Home Assistant Zugriff auf die Seitenleiste hat (Administratoren; Nicht-Admins nur, wenn das Panel für sie freigegeben ist), kommt per Klick auf **alle** Verbindungen von `guacadmin`. Wer das nicht möchte, setzt die Option auf `false`. Ist zusätzlich `totp_enabled` an, fragt Guacamole unter Umständen auch bei Ingress nach dem Code.

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

## Zugriff auf `/share`

Das Add-on bindet den Home-Assistant-Ordner **`/share` mit Schreibrechten** ein (`map: share:rw`). Das Add-on selbst legt dort nichts an – die Freigabe ist für Guacamole-Verbindungen gedacht, die Pfade im Dateisystem des Add-ons brauchen:

- **Laufwerksweiterleitung** (RDP, Option „Laufwerk aktivieren" / *Drive Path*), z. B. `/share/guacamole` – hochgeladene bzw. heruntergeladene Dateien landen dann im HA-Share und sind per Samba oder Datei-Editor erreichbar.
- **Sitzungsaufzeichnungen** (*Recording Path*), z. B. `/share/guacamole/recordings`.

Verzeichnisse unterhalb von `/share` musst du vorher selbst anlegen (Guacamole kann sie optional auch automatisch erstellen lassen). Ohne solche Verbindungseinstellungen wird `/share` nicht genutzt.

## Lizenz

Apache 2.0
