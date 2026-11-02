# Architecture

Flutter, une seule base de code iOS et Android. État géré avec `flutter_bloc` (Cubit), navigation `go_router`, injection `get_it`, stockage `shared_preferences`, notifications `flutter_local_notifications`.

## Dossiers

```
lib/
├── main.dart              point d'entrée, thème, localisation
├── config/                service_locator.dart (get_it), app_router.dart (go_router)
├── core/                  dates, lecture JSON stricte, journal, thème, logo
├── domain/                modèles et règles pures : Settings, DayRecord, QuotaDrawer, QuotaCopy
├── data/                  dépôts (réglages, jours) et erreur de stockage
├── services/              DayPlanner, NotificationScheduler
└── features/              app (état global), onboarding, home, settings, about
```

## Le flux d'une journée

1. `AppCubit.start()` charge les réglages. Absents : onboarding. Illisibles : écran de reprise.
2. `DayPlanner.plan()` s'assure que aujourd'hui et les 29 jours suivants ont un quota (tirage avec `Random.secure()`), marque aujourd'hui comme « vu », supprime ce qui a plus de 90 jours, puis reprogramme les notifications.
3. `HomeCubit` lit le résultat et expose le jour et la semaine. Il se rafraîchit au retour au premier plan, donc à minuit l'écran change de jour.
4. Une notification affiche le quota **déjà tiré** pour ce jour, qui est donc identique à celui de l'app.

## Décisions

| Décision | Raison |
| --- | --- |
| Quotas tirés à l'avance et enregistrés, pas dérivés de la date | Le quota des notifications doit être celui de l'app, et il ne doit pas changer si on touche aux réglages (sinon on peut « chercher » un meilleur tirage). |
| `Random.secure()` injecté dans `QuotaDrawer` | Imprévisible en production, déterministe dans les tests. |
| Jour « vu » (`seen`) | Un jour tiré à l'avance mais jamais ouvert n'apparaît pas dans l'historique : on ne dit pas « respecté » sans l'avoir su. |
| Politique de tirage `DrawPolicy` dans les réglages | Choix de l'utilisateur : figé (défaut) ou recalculé. |
| JSON lu strictement (`readField`) | Un champ absent ou mal typé = données corrompues, jamais une valeur inventée. L'utilisateur choisit de repartir de zéro. |
| Modèles à la main avec `Equatable`, sans Freezed | Peu de modèles, pas de chaîne `build_runner` à maintenir. À revoir si l'app grossit. |
| Pas de `Result<T, E>` | Aucun réseau : la seule erreur possible est `StorageCorruptedException`, gérée par `AppCubit` et `HomeCubit`. |
| Un seul `main.dart`, pas de flavors | Pas de backend, donc un seul environnement. |
| Textes en français dans le code | Une seule langue pour l'instant ; l'extraction vers `intl`/ARB se fera avec l'anglais. |
| Pas de `custom_lint` / `brick_lints` | Les briques partagées ne sont pas utilisées ; `flutter_lints` + règles strictes dans `analysis_options.yaml`. |

## Tests

- `quota_drawer_test` : fourchettes, bornes extrêmes, couverture du hasard total.
- `models_test` : aller-retour JSON, rejet des données invalides.
- `day_planner_test` : tirage à l'avance, quota stable, politique figée/recalculée, plafonds, notifications futures uniquement, purge.
- `app_cubit_test` : onboarding, permission refusée, stockage corrompu, effacement.
- `flow_widget_test` : parcours complet, enregistrement des réglages, effacement, texte à 200 %.

Les widgets sont retrouvés par `Key`, jamais par leur texte.
