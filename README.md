# 🏛️ Statik-Prüfstempel App

Eine moderne, einseitige Webanwendung (Single-Page Application) für Bauingenieure und Statiker, mit der sich PDF-Dokumente einfach und sicher mit einem digitalen "GEPRÜFT"-Stempel versehen lassen.

![Stempel-Vorschau](https://img.shields.io/badge/Status-Einsatzbereit-success?style=for-the-badge)
![Datenschutz](https://img.shields.io/badge/Datenschutz-100%25_Lokal-blue?style=for-the-badge)

## ✨ Funktionen und Merkmale

*   **🔒 100% Datenschutz (Serverless):** Die gesamte PDF-Generierung passiert zwingend lokal im Client (Browser). Es werden *niemals* PDF-Daten an einen externen Server gesendet oder hochgeladen.
*   **🖼️ Intuitive UI:** Modernes "Glassmorphismus"-Design mit dunklem Theme, interner Live-Vorschau und einem Drag-&-Drop Upload-Feld für schnelle Bedienbarkeit.
*   **🖋️ Flexibler Prüfstempel:** 
    *   Der Prüfername kann über ein freies Textfeld dynamisch eingetragen werden.
    *   Datum ist automatisch auf heute gesetzt, aber einfach anpassbar.
    *   Platziert automatisch auf jeder Seite des Dokuments (Unten Rechts).
    *   **Wasserzeichen-Effekt:** Der Stempel (dunkelgrün) ist leicht transparent (`75% Opacity`). Das sorgt dafür, dass Bauzeichnungen und berechnete Werte unter dem Stempel weiterhin lesbar bleiben!
*   **⚡ Keine Abhängigkeiten (Zero-Build-Process):** Reines HTML5, Vanilla JS und Tailwind via CDN.

## 🚀 Installation & Lokale Ausführung

### Option A: Einfach im Browser öffnen (Manuell)
Da die App ohne ein Backend auskommt, reicht es theoretisch schon aus, die `index.html` Datei einfach per Doppelklick in einem Webbrowser (z.B. Chrome, Firefox oder Edge) zu öffnen.

### Option B: Bereitstellung per Docker Compose (Empfohlen)
Um die Applikation als richtigen Webservice z.B. im Firmennetzwerk bereitzustellen, liegt ein `docker-compose.yml` bereit. Dieses baut das Image automatisch und startet den Server.

1. **Starten via Docker Compose:**
   In dem Verzeichnis ausführen:
   ```bash
   docker compose up -d --build
   ```

2. Die Applikation ist nun über Deinen Browser erreichbar unter:
   👉 **`http://localhost:8080`**

*(Um den Dienst wieder zu stoppen, einfach `docker compose down` ausführen)*

## 🛠️ Anpassungen für Entwickler

Das Design und die Stempel-Eigenschaften können einfach im `<script>` oder `<style>` Bereich der `index.html` manipuliert werden.
*   **Stempel-Position & Styles:** Ab ca. Zeile `570` im JavaScript findest Du klar deklarierte Konstanten (z.B. `stampOpacity = 0.75;`, `marginBottom = 20;`), an denen Du die Stempelgröße, Farbe, Transparenz und Position millimetergenau justieren kannst.

## 📚 Verwendeter Tech-Stack

*   **HTML5 / Vanilla JS**: Kernlogik
*   **Tailwind CSS (CDN)**: Styling
*   **pdf-lib (CDN)**: Die Engine für das clientseitige, sichere Lesen, Modifizieren und Speichern der PDF-Datei direkt im ArrayBuffer des Browsers.
