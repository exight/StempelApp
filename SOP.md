# Standard Operating Procedures (SOP) – Stempelapp

> **Operations Runbook für Stempelapp Arbeitszeiterfassung**

Verbindliche Standardarbeitsanweisungen für den initialen Rollout, Routine-Betrieb, die Datensicherung, Notfallwiederherstellung (Disaster Recovery), Störungsbehebung (Incident Management) und planmäßige Wartung im Homelab.

---

## Dokumenten-Metadaten

| Attribut | Wert |
| :--- | :--- |
| **Geltungsbereich** | Stempelapp (https://pruefstempel.wuppt.de) |
| **Systemkomponenten** | stempelapp, PostgreSQL (stempelapp db), Traefik |
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
Deployment der Arbeitszeiterfassungs-Anwendung mit PostgreSQL-Backend und Traefik-Routing.

### Schritt-für-Schritt Rollout
```bash
cd /home/flo/container/stempelapp
# 1. Umgebungsdatei prüfen (DB_HOST, DB_NAME, DB_PASSWORD)
test -f .env || cp .env.example .env
# 2. Prüfen, ob die PostgreSQL-Datenbank 'stempelapp' existiert
docker exec postgres pg_isready -U postgres
# 3. Container starten
docker compose up -d
# 4. Startup-Logs prüfen
docker compose logs -f --tail=30
```

### Besondere Setup-Hinweise
- Erreichbar unter `https://pruefstempel.wuppt.de` auf Port 80.
- Verbindet sich intern über das Netzwerk 'database' mit PostgreSQL.
- Eigene Benutzer- und Zeiterfassungslogik.

---

## SOP-02: Routine-Betrieb, Healthcheck & Monitoring

### Ziel
Überwachung der Erreichbarkeit, Zeiterfassungs-Buchungen und Datenbank-Verbindungen.

### Tägliche & Wöchentliche Prüfschritte
```bash
docker compose ps
curl -kfsSL -o /dev/null -w "HTTP: %{http_code}\n" https://pruefstempel.wuppt.de
docker compose logs --tail=30 | grep -iE 'error|exception'
```

### Überwachung & Metriken
- HTTP Status 200
- Stempel-Buchungen (Kommen/Gehen) werden sofort quittiert
- PostgreSQL-Verbindung stabil

---

## SOP-03: Backup & Datensicherung

### DRP-Einstufung: **Tier 2: Business & Personal Data**
- **Maximaler Datenverlust (RPO):** `< 24 Stunden (täglich um 00:00 Uhr)`
- **Maximale Ausfallzeit (RTO):** `< 1 Stunde`

### Backup-Verfahren
- Tägliches logisches Backup der PostgreSQL-Datenbank `stempelapp` via Databasus.
- Sicherung der `.env` im Passwort-Tresor.

### Manuelle Sicherungsbefehle
```bash
# Ad-hoc Backup der Stempelapp-Datenbank
docker exec -i postgres pg_dump -U postgres -Fc stempelapp > /tmp/stempelapp_backup_$(date +%F_%H%M%S).dump
ls -lh /tmp/stempelapp_backup_*.dump
```

---

## SOP-04: Disaster Recovery & Restore-Verfahren

### Ziel
Wiederherstellung des vollständigen Dienstes und aller Nutzdaten nach Datenverlust, Host-Neuinstallation oder Hardware-Defekt.

### Notfall-Runbook (Schritt-für-Schritt)
```bash
# 1. Container stoppen
docker compose down
# 2. Datenbank aus Databasus wiederherstellen
RESTORE_FILE=$(ls -t /data/backup/homelab/databases/backups/stempelapp*.dump 2>/dev/null | head -n1)
docker exec -i postgres dropdb -U postgres --if-exists stempelapp
docker exec -i postgres createdb -U postgres stempelapp
docker exec -i postgres pg_restore -U postgres -d stempelapp "$RESTORE_FILE"
# 3. Container starten
docker compose up -d
# 4. Prüfen
docker compose logs -f --tail=30
```

### Verifikationskriterien nach dem Restore
- [ ] Webseite https://pruefstempel.wuppt.de lädt einwandfrei
- [ ] Arbeitszeitbuchungen und Benutzerprofile sind vorhanden
- [ ] Neue Buchung lässt sich fehlerfrei speichern

---

## SOP-05: Incident Management & Störungsbehebung

### Störfall: Datenbank-Verbindung unterbrochen / HTTP 500
**Symptome:** Anwendung wirft HTTP 500 beim Speichern von Stempelzeiten.

**Diagnose & Behebung:**
```bash
# 1. Verbindung von stempelapp zu postgres prüfen
docker network inspect database | grep stempelapp
# 2. PostgreSQL Logs prüfen
docker logs postgres --tail=50
# 3. Container neu starten
docker compose restart
```

---

## SOP-06: Wartung, Updates & Bereinigung

### Planmäßige Aktualisierung
```bash
docker compose pull
docker compose up -d
docker image prune -f
```

### Housekeeping & Bereinigung
- Jährlicher Export von Arbeitszeitnachweisen für Archivierungszwecke.

