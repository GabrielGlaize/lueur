# Lueur : avant la diffusion

Ce qui reste à faire par un humain avant de donner l'app à des testeurs, puis de la publier. Le code de la version 2.0.0 est prêt ; rien de cette liste ne se fait sans compte, sans décision ou sans argent.

## 1. Décisions et textes

- [ ] Acheter le domaine et créer l'adresse de contact, puis l'ajouter à l'écran « À propos et aide ».
- [ ] Faire relire le texte de confidentialité (`lib/features/about/about_page.dart`).
- [ ] Publier ce texte sur une page web : les deux stores demandent une URL.
- [ ] Choisir la licence du dépôt si le code devient public (aucune aujourd'hui, donc tous droits réservés).
- [ ] Vérifier la règle de l'App Store sur les apps liées au tabac : une app qui aide à réduire est acceptée, mais l'avertissement santé et l'absence de promotion doivent rester visibles. Remplir la classification d'âge en conséquence.
- [ ] Google Play : remplir la déclaration « applications de santé » et la section sécurité des données (« aucune donnée collectée »).

## 2. Technique

- [ ] Ajouter `ios/Runner/PrivacyInfo.xcprivacy` (déclarer l'usage de `UserDefaults`, raison CA92.1) et l'inclure dans la cible Runner.
- [ ] Créer une clé de signature Android, la garder précieusement (la perdre empêche toute mise à jour), et remplacer la signature de debug de la release.
- [ ] Essayer sur un vrai iPhone et un vrai Android : permission de notification, rappel à l'heure choisie, redémarrage du téléphone, changement de fuseau, passage à minuit app ouverte.
- [ ] Passage VoiceOver et TalkBack à la main.
- [ ] Pousser le dépôt sur GitHub pour que la CI tourne.

## 3. Version de test

- **iPhone** : compte Apple Developer (99 €/an) puis TestFlight. Sans lui, l'app expire au bout de 7 jours sur un iPhone branché.
- **Android** : APK signé envoyé directement, ou compte Play Console (25 $, une fois) pour un test fermé.
- Identifiant sur les deux plateformes : `dev.gabrielglaize.lueur`.

## 4. Fiches des stores

- [ ] Captures iPhone et Android (accueil, onboarding, réglages, clair et sombre).
- [ ] Description courte et longue, mots-clés, icône 1024.
