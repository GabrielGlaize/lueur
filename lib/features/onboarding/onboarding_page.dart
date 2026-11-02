import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../core/widgets/lueur_logo.dart";
import "../../domain/settings.dart";
import "../app/app_cubit.dart";
import "../settings/settings_fields.dart";

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const int _lastStep = 2;

  int _step = 0;
  Settings _draft = Settings.initial;
  bool _saving = false;

  Future<void> _finish() async {
    setState(() => _saving = true);
    final kept = await context.read<AppCubit>().completeOnboarding(_draft);
    if (!mounted || kept) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Les notifications sont refusées : tu peux les activer dans les réglages du téléphone.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: switch (_step) {
                  0 => const _Welcome(),
                  1 => _Choices(
                    draft: _draft,
                    onChanged: (s) => setState(() => _draft = s),
                  ),
                  _ => _Reminder(
                    draft: _draft,
                    onChanged: (s) => setState(() => _draft = s),
                  ),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: [
                  Semantics(
                    label: "Étape ${_step + 1} sur ${_lastStep + 1}",
                    child: ExcludeSemantics(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i <= _lastStep; i++)
                            Container(
                              width: i == _step ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: i == _step
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: OutlinedButton(
                            key: const Key("onboarding-back-btn"),
                            onPressed: _saving
                                ? null
                                : () => setState(() => _step--),
                            child: const Text("Retour"),
                          ),
                        ),
                      if (_step > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          key: const Key("onboarding-next-btn"),
                          onPressed: _saving
                              ? null
                              : _step == _lastStep
                              ? _finish
                              : () => setState(() => _step++),
                          child: Text(
                            _step == 0
                                ? "Commencer"
                                : _step == _lastStep
                                ? "Terminer"
                                : "Continuer",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Center(child: LueurLogo(size: 120)),
        const SizedBox(height: 32),
        Semantics(
          header: true,
          child: Text(
            "Lueur",
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Chaque matin, un quota de cigarettes tiré au hasard, pour apprendre à te limiter en douceur et sans parler d’argent.",
          style: theme.textTheme.titleMedium?.copyWith(height: 1.4),
        ),
        const SizedBox(height: 20),
        Text(
          "Tout reste sur ton téléphone : pas de compte, aucune donnée envoyée. "
          "Lueur est un repère personnel, pas un dispositif médical.",
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _Choices extends StatelessWidget {
  const _Choices({required this.draft, required this.onChanged});

  final Settings draft;
  final ValueChanged<Settings> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(
          "Ton rythme",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      const SizedBox(height: 24),
      MaximumField(settings: draft, onChanged: onChanged),
      const SizedBox(height: 28),
      ModeField(settings: draft, onChanged: onChanged),
    ],
  );
}

class _Reminder extends StatelessWidget {
  const _Reminder({required this.draft, required this.onChanged});

  final Settings draft;
  final ValueChanged<Settings> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(
          "Chaque jour",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      const SizedBox(height: 24),
      DrawPolicyField(settings: draft, onChanged: onChanged),
      const SizedBox(height: 24),
      NotificationField(settings: draft, onChanged: onChanged),
    ],
  );
}
