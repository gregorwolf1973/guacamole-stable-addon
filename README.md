# Gregor's Guacamole Stable Add-ons

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/gregorwolf1973)

Home Assistant Add-on Repository für eine stabile Apache Guacamole Installation.

## Installation

1. In Home Assistant: **Einstellungen → Apps → App installieren → ⋮ → Repositories**
2. URL hinzufügen: `https://github.com/gregorwolf1973/guacamole-stable-addon`
3. Add-on **Guacamole Stable** installieren

## Add-ons

### [Guacamole Stable](./guacamole)

Apache Guacamole 1.5.5 mit selbst kompilierter FreeRDP 2.11.7. Bewusst auf diesen Versionen festgenagelt: das FreeRDP-Paket aus Ubuntu 22.04 (2.6.1) hat einen Fehler beim Ignorieren von Serverzertifikaten, der RDP-Verbindungen zu xrdp-Servern unmöglich macht. Details siehe [Changelog](./guacamole/CHANGELOG.md).

## Lizenz

Apache 2.0
