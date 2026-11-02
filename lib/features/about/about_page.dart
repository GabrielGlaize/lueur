import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String version = "2.0.0";

  Future<void> _call() => launchUrl(Uri(scheme: "tel", path: "3989"));

  Future<void> _openSite() => launchUrl(
    Uri.parse("https://www.tabac-info-service.fr"),
    mode: LaunchMode.externalApplication,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("À propos et aide")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const _Section(
              title: "Ce que Lueur est",
              body:
                  "Un repère personnel pour observer et réduire ta consommation de "
                  "cigarettes. Ce n’est ni un dispositif médical ni un programme de "
                  "sevrage, et il ne remplace pas l’avis d’un professionnel de santé.",
            ),
            const SizedBox(height: 24),
            Text(
              "Besoin d’un coup de main ?",
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              "Tabac Info Service accompagne gratuitement celles et ceux qui "
              "veulent arrêter ou réduire : 39 89 (service gratuit, appel non "
              "surtaxé), du lundi au samedi de 8 h à 20 h.",
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key("about-call-btn"),
              onPressed: _call,
              icon: const Icon(Icons.call),
              label: const Text("Appeler le 39 89"),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: const Key("about-site-btn"),
              onPressed: _openSite,
              icon: const Icon(Icons.open_in_new),
              label: const Text("tabac-info-service.fr"),
            ),
            const SizedBox(height: 24),
            const _Section(
              title: "Tes données",
              body:
                  "Tout reste sur ton téléphone : réglages, quotas et historique. "
                  "Lueur n’a pas de compte, pas de serveur, aucun outil de mesure "
                  "d’audience ni de publicité, et ne transmet rien à personne. "
                  "Les notifications sont programmées localement par ton téléphone. "
                  "Tu peux tout effacer à tout moment depuis les réglages ; "
                  "désinstaller l’app supprime aussi tout.",
            ),
            const SizedBox(height: 24),
            const _Section(
              title: "Éditeur",
              body:
                  "Application personnelle de Gabriel Glaize, développée sur son "
                  "temps libre. Sans garantie : les quotas sont tirés au hasard et "
                  "ne constituent pas un conseil médical.",
            ),
            const SizedBox(height: 24),
            Text(
              "Version $version",
              key: const Key("about-version"),
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      const SizedBox(height: 8),
      Text(body, style: const TextStyle(height: 1.4)),
    ],
  );
}
