# 🏛️ Statik-Prüfstempel App

> **Clientseitige Single-Page Web-App für digitale PDF-Prüfstempel**

Moderne, einseitige Webanwendung (SPA) für Bauingenieure und Statiker, mit der sich PDF-Dokumente einfach und sicher mit einem digitalen 'GEPRÜFT'-Stempel versehen lassen. Die gesamte PDF-Modifikation geschieht zu 100% lokal im Browser des Nutzers via pdf-lib – es werden keine Dokumente hochgeladen.

---

## 1. 📌 Architektur & Container-Konfiguration

- **Kategorie (Homepage):** `Productivity & Tools`
- **Betriebsstatus:** `Produktiv aktiv`
- **DRP-Klassifizierung:** **Tier 4 (Statisch / Zustandslos)** (siehe [Disaster Recovery Plan](file:///home/flo/container/disaster_recovery.md))

### Container-Übersicht

| Container | Image | Ressourcen-Limits | Netzwerke | Externe Ports |
| :--- | :--- | :--- | :--- | :--- |
| `digitaler-stempel` | `Lokal gebaut (Dockerfile via nginx:alpine)` | CPU: 0.25 / RAM: 64M | `proxy` | Keine (Traefik-only) |

## 2. 🌐 Erreichbarkeit & Routing (Traefik)

- **Primäre Web-Adresse:** [https://pruefstempel.wuppt.de](https://pruefstempel.wuppt.de)

### Traefik Reverse-Proxy Ingress

| Parameter | Konfiguration / Wert |
| :--- | :--- |
| **Router-Name** | `stempel` |
| **Routing-Regel (Rule)** | `Host(`pruefstempel.wuppt.de`)` |
| **EntryPoints** | `https` (Port 443 mit automatischer HTTPS-Erzwingung) |
| **TLS-Zertifikat** | `cloudflare` (Wildcard `*.wuppt.de` via DNS-01 Challenge) |
| **Interner Service-Port** | `80` |
| **Aktive Middlewares** | Keine (Direkte Weiterleitung) |

## 3. 🔐 Authentifizierung & Zugriffskontrolle

- **Authentifizierungs-Methode:** **Öffentlich / Clientseitig isoliert (Zero-Knowledge)**
- **Sicherheitskonzept & Funktionsweise:**
  Die Anwendung ist öffentlich erreichbar. Da PDFs niemals an den Server übertragen werden, sondern clientseitig im WebAssembly/JavaScript-ArrayBuffer verarbeitet werden, ist absoluter Datenschutz für vertrauliche Baupläne garantiert.
- **Ausnahmen & API-Freigaben:**
  Kein vorgeschaltetes Proxy-Gateway erforderlich.

### Container-Hardening & Least-Privilege
- **Container `digitaler-stempel`:**
  - No-New-Privileges: Aktiviert (`no-new-privileges:true`)
  - Read-Only Root-FS: Aktiviert (`read_only: true`)
  - Linux Capabilities: `CHOWN, SETUID, SETGID, NET_BIND_SERVICE`
  - Prozess-Benutzer: `nginx`

## 4. 🔗 Abhängigkeiten & Systemintegration

- **Datenbank:** Keine
- **Docker-Netzwerke:** proxy
- **Homelab-Abhängigkeiten:** Traefik
- **Externe Schnittstellen:** Keine (Zero-Dependency-Build, HTML/JS/CSS ausgeliefert via Nginx)

## 5. 💾 Speicherpfade & Persistenz

| Host-Pfad | Container-Pfad | Modus | Inhalt / Zweck | Datensicherung |
| :--- | :--- | :--- | :--- | :--- |

## 6. ⚙️ Besonderheiten & Spezifische Konfiguration

- **Container-Hardening:** `read_only: true` mit `tmpfs: [/var/cache/nginx, /var/run, /tmp]`, `cap_drop: [ALL]`.
- **Wasserzeichen-Effekt:** Der Stempel ist mit 75% Deckkraft leicht transparent, damit Zahlen und Planinhalte darunter lesbar bleiben.

## 7. 🛡️ Backup & Disaster Recovery (DRP)

- **Klassifizierung:** **Tier 4 (Statisch / Zustandslos)** nach [`disaster_recovery.md`](file:///home/flo/container/disaster_recovery.md)
- **Recovery Time Objective (RTO):** `< 5 Minuten`
- **Recovery Point Objective (RPO):** `0 Minuten`
- **Datenbank-Sicherung (Databasus):** Nicht zutreffend
- **Dateisystem-Sicherung (Backrest):** In Git versioniert
- **Wiederherstellungsprozess:**
  Neustart bzw. Rebuild via Docker Compose.

## 8. 📊 Dashboard & Monitoring

- **Homepage Dashboard:**
  - **Kategorie:** `Productivity & Tools`
  - **Icon:** `mdi-stamp`
  - **Verlinkung:** [https://pruefstempel.wuppt.de](https://pruefstempel.wuppt.de)
- **Uptime Kuma:** HTTP-Endpunkt-Check auf [https://pruefstempel.wuppt.de](https://pruefstempel.wuppt.de)
- **Metriken & Logging:** Healthcheck `wget -qO /dev/null http://127.0.0.1/` alle 30s

## 9. 🚀 Betrieb & Wartung

```bash
# In das Projektverzeichnis wechseln
cd /home/flo/container/stempelapp

# Status & Healthcheck der Container prüfen
docker compose ps

# Live-Logs verfolgen
docker compose logs -f

# Service neu starten
docker compose restart

# Image aktualisieren und Container neu erstellen
docker compose pull
docker compose up -d
```

### Spezifische Wartungshinweise
- Stempel-Position und Farben können direkt in `index.html` angepasst werden.

