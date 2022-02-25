# NEON CLI

Developed mit 💙 by NEON Software Studios

---

Ein Command Line Interface für Dart, das nur ein Gas kennt.

## Installieren

Du hast dir das Repo ja offensichtlich irgendwo hingeklont. Jetzt musst du es nur noch
global aktivieren:

```sh
dart pub global activate --source path pfad/zu/diesem/verzeichnis
```

Pro Tip: Falls du gerade im Verzeichnis bist, in das du das Repo geklont hast, dann funktioniert auch ein relativer Pfad:

```sh
dart pub global activate --source path ./NEON_cli
```

## Commands

### `NEON abfahrt`

Erstellt dir ein neues Flutter Projekt anhand des [NEON Template Project][template_project_link]. Dauert ungefähr 3.5 Tornados 🍺

### `NEON update``

Updated die NEON CLI. Übergib über das ```cli-path``` Flag den absoluten Pfad zu dem CLI-Ordner auf deinem Rechner oder sei ein High-Performer und installiere die CLI im Verzeichnis ```~/NEON_cli```, um dir das Flag zu sparen!

```sh
🥵 Ein absolutes High-Performer-Tool, vom wilden Typen für wilde Typen.

Usage: NEON <command> [arguments]

Global options:
-h, --help       Print this usage information.
    --version    Einmal die aktuelle Version to go bitte.

Available commands:
  abfahrt   NEON abfahrt <projektname>
             Erstellt ein neues Projekt mit dem angegebenen Namen nach NEON Maßstäben (to the 🌝) im aktuellen Verzeichnis.
  update    NEON update
            Updated die NEON CLI auf den neuesten Stand der Dinge
```

#### Wie funktioniert's?

```sh
# Erstelle eine neue App, die geile_app heißt:
NEON abfahrt geile_app
```

#### Was lass ich mich hier auf die Platte schießen?

Alles, was das Template Project drauf hat, findest du im [README des Projektes][template_project_link], unter "What's in the box?"

### `NEON --help`

Für die Hilflosen unter uns.

[template_project_link]: https://github.com/julien-neon/NEON_template_project
