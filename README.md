# BSK Op Jück – Vereinsverwaltung

Vereinsverwaltung im Browser: Mitglieder, Beiträge & Mahnwesen, SEPA-Lastschrift, Buchhaltung/EÜR, Schriftverkehr, Excel/CSV-Import – **mit Team-Betrieb**: gemeinsame Daten auf einem kostenlosen Server, Login für alle Vorstände, Benutzerverwaltung mit Admin-Rolle.

Alles kostenlos: GitHub Pages (Webseite) + Supabase Free (Datenbank & Login).

---

## Teil 1: Webseite online stellen (GitHub Pages, ~5 Minuten)

1. Konto auf github.com anlegen, neues **öffentliches** Repository erstellen (z. B. `vereinsverwaltung`).
2. `index.html` hochladen (Add file → Upload files → Commit changes).
3. **Settings → Pages** → Branch `main`, Ordner `/ (root)` → Save.
4. Nach 1–2 Minuten läuft die Seite unter `https://DEINNAME.github.io/vereinsverwaltung/`.

Alternative **Render**: render.com → New → Static Site → GitHub-Repo wählen → Publish Directory `.` → fertig. Static Sites sind bei Render dauerhaft kostenlos.

Die Seite selbst enthält keine Vereinsdaten – ohne Login sieht man nur eine leere App.

## Teil 2: Server für Team-Betrieb (Supabase, ~10 Minuten)

1. Konto auf **supabase.com** anlegen (kostenlos, keine Kreditkarte) → **New project** (Region z. B. Frankfurt, Datenbank-Passwort gut aufbewahren).
2. Links **SQL Editor** → New query → den kompletten Inhalt von `supabase-setup.sql` einfügen → **Run**. (Legt Tabellen, Trigger und Zugriffsregeln an.)
3. **Authentication → Sign In / Providers → Email**: „Confirm email“ **ausschalten** (sonst braucht jeder Vorstand erst einen Bestätigungslink; mit nur 4 bekannten Nutzern unnötig).
4. **Project Settings → API**: die **Project URL** (https://xxxx.supabase.co) und den **anon/public Key** kopieren.
5. Eure veröffentlichte Seite öffnen → Menü **Team & Cloud** → URL und Key eintragen → „Verbinden & neu laden“.
6. Über „Konto erstellen“ registrieren (Name, E-Mail, Passwort).
7. Zurück im Supabase **SQL Editor** die letzte Zeile aus `supabase-setup.sql` mit deiner E-Mail ausführen:
   `update public.profiles set role='admin', approved=true where email='DEINE@MAIL.DE';`
8. Seite neu laden, anmelden → beim ersten Mal fragt die App, ob die lokalen Daten als gemeinsamer Startstand hochgeladen werden sollen.
9. Die anderen 3 Vorstände: Seite öffnen → „Konto erstellen“. Du schaltest sie unter **Team & Cloud → Benutzerverwaltung** frei (Häkchen „Frei“) und kannst dort Rollen (Admin/Vorstand) vergeben oder Zugriff wieder entziehen.

### So arbeitet das Team
- Jede Änderung wird ca. 1 Sekunde nach dem Speichern zum Server geschrieben; alle 25 Sekunden holt die App Änderungen der anderen.
- Ändern zwei Personen gleichzeitig, erscheint ein Dialog: Server-Stand übernehmen oder eigene Version erzwingen.
- Der Status unten links in der Seitenleiste zeigt „Cloud: gespeichert HH:MM“.
- Backups (Einstellungen → Backup herunterladen) bleiben trotzdem Pflicht – ein JSON pro Woche schadet nie.

### Kosten & Grenzen (Stand der Free-Tarife)
- GitHub Pages: kostenlos, keine relevanten Grenzen für euch.
- Supabase Free: 500 MB Datenbank, 50.000 monatlich aktive Nutzer – für einen Verein praktisch unerreichbar. **Einzige Einschränkung:** Projekte werden nach ca. 1 Woche ohne jegliche Nutzung pausiert; beim nächsten Login ins Supabase-Dashboard mit einem Klick wieder aufweckbar. Bei wöchentlicher Vereinsnutzung passiert das in der Regel nicht.

### Sicherheit
- Der „anon“-Key darf öffentlich in der Seite stehen – er erlaubt nur Anmeldung/Registrierung. Auf die Vereinsdaten kommt man ausschließlich mit Login **und** Freischaltung durch den Admin (serverseitige Row-Level-Security).
- Konten endgültig löschen: Supabase-Dashboard → Authentication → Users.

## Updates einspielen
Neue `index.html` einfach im GitHub-Repository hochladen (alte überschreiben) – die Seite aktualisiert sich automatisch, Daten liegen ja auf dem Server.


## Teil 3: Als App aufs Handy und den PC („Home-App“)

Sobald die Seite online ist (Teil 1), kann sie jeder wie eine normale App installieren – ohne App-Store:

- **Android (Chrome):** Seite öffnen → Drei-Punkte-Menü → **„App installieren“** bzw. „Zum Startbildschirm hinzufügen“ → das BSK-Icon liegt dann wie eine App auf dem Handy.
- **iPhone (Safari):** Seite öffnen → **Teilen-Symbol** (Viereck mit Pfeil) → **„Zum Home-Bildschirm“**.
- **PC (Chrome/Edge):** Seite öffnen → **Installieren-Symbol** rechts in der Adressleiste (Monitor mit Pfeil) → die Verwaltung läuft dann als eigenes Fenster mit Icon in der Taskleiste.

Die App startet dank Offline-Speicher auch ohne Internet (zum Nachschauen); zum gemeinsamen Arbeiten und Synchronisieren braucht sie natürlich Verbindung zum Vereinsserver (Teil 2).

**Wichtig:** Damit die Vorstände ohne Claude-Konten gemeinsam arbeiten (Login, Admin-Freischaltung, gleiche Daten überall), muss Teil 2 (Supabase) eingerichtet sein – die Anleitung dafür steht oben, das SQL-Skript liegt bei.
