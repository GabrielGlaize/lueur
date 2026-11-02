# Niveau de qualité de Lueur

État au 2 novembre 2026. « Vérifié » veut dire qu'une commande ou un test l'a prouvé ; « À faire » est dit sans détour.

## Sécurité et confidentialité

| Point | État |
| --- | --- |
| Aucune donnée ne quitte le téléphone (pas de réseau, pas de compte, pas de mesure d'audience) | Vérifié : aucune dépendance réseau dans `pubspec.yaml` ; seul `url_launcher` ouvre le 39 89 et le site de Tabac Info Service à la demande de l'utilisateur |
| Pas de secret ni de clé dans le dépôt | Vérifié (aucun) |
| Sauvegarde cloud Android désactivée (`allowBackup=false`) : l'historique ne part pas chez Google | Vérifié dans le manifeste |
| Tirage imprévisible (`Random.secure()`) et non rejouable en changeant les réglages | Vérifié par tests |
| Données illisibles : jamais de valeur inventée, l'utilisateur choisit de tout effacer | Vérifié par tests |
| Effacement complet depuis les réglages | Vérifié par test d'interface |
| Manifeste de confidentialité Apple (`PrivacyInfo.xcprivacy`) | **À faire** : aucun dans le projet (voir AVANT_DIFFUSION) |
| Signature de release Android | **À faire** : la release est encore signée avec la clé de debug |

## Bugs

- 27 tests, analyse sans avertissement (`strict-casts`, `strict-inference`, `strict-raw-types`).
- Deux défauts trouvés et corrigés pendant la refonte grâce aux tests : plantage de l'accueil après « Tout effacer », et anneau du quota qui débordait à 200 % de taille de texte.
- Pas encore essayé sur un vrai téléphone : le planning réel des notifications, la demande de permission et le comportement après redémarrage ne sont prouvés que par des faux en test.

## Accessibilité

- Zones tactiles d'au moins 48 dp, libellés (`tooltip`, `Semantics`) sur les boutons-icônes, le curseur et l'anneau du quota, titres déclarés comme tels, changement de statut annoncé (`liveRegion`).
- L'état n'est jamais porté par la seule couleur : « dans le quota » / « quota dépassé » sont écrits.
- Contrastes calculés à la main, au moins 4,5:1 dans les deux thèmes (texte courant et accent). Pas encore mesuré par un outil.
- Texte agrandi à 200 % : aucun débordement sur l'onboarding, l'accueil et l'aide (test automatique).
- Animation du logo coupée quand l'utilisateur réduit les animations (test automatique).
- **À faire** : passage VoiceOver et TalkBack à la main, vérification du mode « gras » iOS et du contraste forcé.

## Légal

- Avertissement santé (outil de repérage, pas un dispositif médical) à l'accueil et dans « À propos et aide ».
- Orientation vers Tabac Info Service (39 89, gratuit) avec appel en un geste.
- Politique de confidentialité intégrée à l'app, en langage simple.
- **À faire** : l'App Store et Google Play demandent une URL publique de politique de confidentialité (à publier sur le futur site) ; une adresse de contact (`contact@gabrielglaize.dev`, domaine pas encore acheté) ; relecture des textes (brouillons, pas un avis juridique).

## Design, UX, UI

- Une identité (anneau et point lumineux), deux thèmes suivant le téléphone, hiérarchie simple : un seul chiffre au centre de l'accueil.
- Ton sans jugement : un dépassement dit « ce n'est pas grave, demain repart à zéro ».
- Les quatre états sont traités : chargement, données illisibles, vide (première utilisation), prêt.
- Le bouton « Enregistrer » des réglages est fixé en bas, toujours atteignable.
- Vérifié à l'écran (simulateur iPhone 17 Pro, clair et sombre) : l'écran de bienvenue seulement. **À faire** : captures et vérification à l'écran de l'accueil et des réglages (les tests d'interface les couvrent, pas l'œil).
- Une seule langue (français) ; textes à extraire pour ajouter l'anglais.

## Compilation

- iOS simulateur : compile (`./scripts/build-ios-sim.sh`).
- Android : `flutter build apk --debug` compile.
- CI GitHub : format, analyse, tests (`.github/workflows/ci.yml`), exécutée avec succès le 2 novembre 2026 sur le dépôt privé `GabrielGlaize/lueur`.
