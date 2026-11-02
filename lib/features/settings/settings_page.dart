import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../../domain/settings.dart";
import "../app/app_cubit.dart";
import "../app/app_state.dart";
import "settings_fields.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Settings _saved = _current();
  late Settings _draft = _saved;
  bool _saving = false;

  Settings _current() {
    final state = context.read<AppCubit>().state;
    if (state is! AppReady) {
      throw StateError("Settings opened before the app was ready");
    }
    return state.settings;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final kept = await context.read<AppCubit>().updateSettings(_draft);
    if (!mounted) return;
    final state = context.read<AppCubit>().state;
    setState(() {
      _saving = false;
      _saved = (state as AppReady).settings;
      _draft = _saved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          kept
              ? "Réglages enregistrés."
              : "Enregistré, mais les notifications sont refusées dans les réglages du téléphone.",
        ),
      ),
    );
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tout effacer ?"),
        content: const Text(
          "Tes réglages et ton historique seront supprimés de ce téléphone. "
          "Cette action est définitive.",
        ),
        actions: [
          TextButton(
            key: const Key("reset-cancel-btn"),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Annuler"),
          ),
          FilledButton(
            key: const Key("reset-confirm-btn"),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Tout effacer"),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AppCubit>().resetEverything();
    if (mounted) context.go("/onboarding");
  }

  @override
  Widget build(BuildContext context) {
    final changed = _draft != _saved;
    return Scaffold(
      appBar: AppBar(title: const Text("Réglages")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  MaximumField(
                    settings: _draft,
                    onChanged: (s) => setState(() => _draft = s),
                  ),
                  const SizedBox(height: 28),
                  ModeField(
                    settings: _draft,
                    onChanged: (s) => setState(() => _draft = s),
                  ),
                  const SizedBox(height: 28),
                  DrawPolicyField(
                    settings: _draft,
                    onChanged: (s) => setState(() => _draft = s),
                  ),
                  const SizedBox(height: 20),
                  NotificationField(
                    settings: _draft,
                    onChanged: (s) => setState(() => _draft = s),
                  ),
                  const SizedBox(height: 28),
                  OutlinedButton.icon(
                    key: const Key("settings-reset-btn"),
                    onPressed: _confirmReset,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Effacer toutes mes données"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key("settings-save-btn"),
                  onPressed: changed && !_saving ? _save : null,
                  child: const Text("Enregistrer"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
