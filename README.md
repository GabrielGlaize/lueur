# Lueur

Application mobile (Flutter, iOS et Android) qui tire chaque matin un quota de cigarettes au hasard, pour apprendre à se limiter en douceur et sans parler d'argent. Tout reste sur le téléphone : pas de compte, pas de serveur, aucune donnée envoyée.

Projet personnel de Gabriel Glaize, refondu en novembre 2026 (première version générée avec Codex en juillet 2026).

## Ce que fait l'app

- Onboarding en trois étapes : maximum habituel, type de tirage, rappel.
- Deux tirages : **progressif** (une fourchette selon l'allure douce, équilibre ou intense) ou **hasard total** (de 1 au maximum).
- **Quota du jour figé ou recalculé**, au choix dans les réglages : figé, il ne bouge plus une fois tiré (les nouveaux réglages valent dès demain) ; recalculé, il est tiré à nouveau si on change le maximum ou l'allure.
- Compteur du jour avec annulation, historique des 7 derniers jours.
- Notification locale chaque matin avec le quota (30 jours programmés à l'avance).
- Thèmes clair et sombre suivant le téléphone, texte agrandi pris en charge, animation coupée si l'utilisateur réduit les animations.
- Page « À propos et aide » : confidentialité, avertissement santé, Tabac Info Service (39 89).
- Effacement complet des données depuis les réglages.

## Lancer le projet

```sh
flutter pub get
flutter run
```

**Compiler pour le simulateur iPhone depuis ce dossier échoue** (`resource fork, Finder information, or similar detritus not allowed`) parce que `~/Documents` est synchronisé par iCloud. Utiliser le script, qui compile depuis une copie hors de Documents :

```sh
./scripts/build-ios-sim.sh
```

## Vérifier

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

La même chose tourne en CI (`.github/workflows/ci.yml`).

## Où est quoi

Voir [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Le niveau de qualité (sécurité, accessibilité, légal…) et ce qui reste à faire sont dans [docs/QUALITE.md](docs/QUALITE.md) et [docs/AVANT_DIFFUSION.md](docs/AVANT_DIFFUSION.md).

Lueur est un outil de repérage personnel : il ne remplace pas un accompagnement médical au sevrage tabagique.
