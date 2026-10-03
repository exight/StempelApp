# Standard Operating Procedures (SOP) – Stempelapp

> **Operations Runbook für die Statik-Prüfstempel App (statische PDF-Stempel-SPA)**

Verbindliche Standardarbeitsanweisungen für den initialen Rollout, Routine-Betrieb, die Datensicherung, Notfallwiederherstellung (Disaster Recovery), Störungsbehebung (Incident Management) und planmäßige Wartung im Homelab.

---

## Dokumenten-Metadaten

| Attribut | Wert |
| :--- | :--- |
| **Geltungsbereich** | Stempelapp (https://pruefstempel.wuppt.de) |
| **Systemkomponenten** | digitaler-stempel (lokal gebautes nginx:alpine-Image mit `index.html`), Traefik |
| **Verantwortlich** | Homelab-Administrator / Coding-Agents |
| **DRP-Klassifizierung** | **Tier 2: Business & Personal Data** |
| **Zugehörige Dokumente** | [`stempelapp/README.md`](file:///home/flo/container/stempelapp/README.md), [`disaster_recovery.md`](file:///home/flo/container/disaster_recovery.md), [`best_practices.md`](file:///home/flo/container/best_practices.md), [`AGENTS.md`](file:///home/flo/container/AGENTS.md) |

---

## Übersicht der Standard Operating Procedures

- [SOP-01: Deployment, Start-Routine & Initial-Setup](#sop-01-deployment-start-routine--initial-setup)
- [SOP-02: Routine-Betrieb, Healthcheck & Monitoring](#sop-02-routine-betrieb-healthcheck--monitoring)
- [SOP-03: Backup & Datensicherung](#sop-03-backup--datensicherung)
- [SOP-04: Disaster Recovery & Restore-Verfahren](#sop-04-disaster-recovery--restore-verfahren)
- [SOP-05: Incident Management & Störungsbehebung](#sop-05-incident-management--störungsbehebung)
- [SOP-06: Wartung, Updates & Bereinigung](#sop-06-wartung-updates--bereinigung)

---

## SOP-01: Deployment, Start-Routine & Initial-Setup

### Ziel & Vorbedingungen
Deployment der statischen Prüfstempel-SPA (Nginx, read-only) mit Traefik-Routing. Keine Datenbank, keine `.env`.

### Schritt-für-Schritt Rollout
```bash
cd /home/flo/container/stempelapp
# 1. Image aus Dockerfile bauen (nginx:alpine + index.html)
docker compose build --pull
# 2. Container starten
docker compose up -d
# 3. Startup-Logs prüfen
docker compose logs -f --tail=30
```

### Besondere Setup-Hinweise
- Erreichbar unter `https://pruefstempel.wuppt.de` (Nginx intern auf Port 80).
- Nur im Netzwerk `proxy`; keine Datenbank-Anbindung.
- Die PDF-Verarbeitung erfolgt vollständig clientseitig im Browser (pdf-lib).

---

## SOP-02: Routine-Betrieb, Healthcheck & Monitoring

### Ziel
Überwachung der Erreichbarkeit der statischen Webanwendung.

### Tägliche & Wöchentliche Prüfschritte
```bash
docker compose ps
curl -kfsSL -o /dev/null -w "HTTP: %{http_code}\n" https://pruefstempel.wuppt.de
docker compose logs --tail=30 | grep -iE 'error|emerg|crit'
```

### Überwachung & Metriken
- HTTP Status 200
- Docker-Healthcheck (`wget http://127.0.0.1/`) meldet `healthy`
- PDF lässt sich im Browser stempeln und herunterladen

---

## SOP-03: Backup & Datensicherung

### DRP-Einstufung: **Tier 2: Business & Personal Data**
- **Maximaler Datenverlust (RPO):** `0 (zustandslos, vollständig in Git versioniert)`
- **Maximale Ausfallzeit (RTO):** `< 1 Stunde`

### Backup-Verfahren
- Keine Nutzdaten auf dem Server; PDFs verlassen nie den Browser.
- `Dockerfile`, `index.html` und `docker-compose.yml` sind in Git versioniert.

### Manuelle Sicherungsbefehle
```bash
# Git-Status prüfen
git status -s /home/flo/container/stempelapp
```

---

## SOP-04: Disaster Recovery & Restore-Verfahren

### Ziel
Wiederherstellung des Dienstes nach Container-Defekt, Host-Neuinstallation oder Hardware-Defekt.

### Notfall-Runbook (Schritt-für-Schritt)
```bash
cd /home/flo/container/stempelapp
# 1. Container stoppen
docker compose down
# 2. Image neu bauen und Container starten
docker compose up -d --build
# 3. Prüfen
docker compose logs -f --tail=30
```

### Verifikationskriterien nach dem Restore
- [ ] Webseite https://pruefstempel.wuppt.de lädt einwandfrei
- [ ] Test-PDF lässt sich hochladen (lokal), stempeln und herunterladen

---

## SOP-05: Incident Management & Störungsbehebung

### Störfall: Stempeln funktioniert nicht / leere Seite
**Symptome:** Seite lädt ohne Styling oder der Stempel-Button reagiert nicht.

**Diagnose & Behebung:**
```bash
# 1. Container-Status und Healthcheck prüfen
docker compose ps
# 2. Erreichbarkeit der CDN-Abhängigkeiten (Tailwind, pdf-lib) aus dem Client prüfen
curl -fsSI https://unpkg.com/pdf-lib@1.17.1/dist/pdf-lib.min.js | head -n1
curl -fsSI https://cdn.tailwindcss.com | head -n1
# 3. Container neu starten
docker compose restart
```

---

## SOP-06: Wartung, Updates & Bereinigung

### Planmäßige Aktualisierung
```bash
docker compose build --pull
docker compose up -d
docker image prune -f
```

### Housekeeping & Bereinigung
- Anpassungen an Stempel-Layout, Farben oder Deckkraft erfolgen in `index.html` (danach neu bauen).
