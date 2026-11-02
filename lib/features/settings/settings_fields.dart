import "package:flutter/material.dart";

import "../../domain/enums.dart";
import "../../domain/settings.dart";

/// Form pieces shared by onboarding and the settings page. Each one edits a
/// draft [Settings] and reports the new draft through [onChanged].
class MaximumField extends StatelessWidget {
  const MaximumField({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final Settings settings;
  final ValueChanged<Settings> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = settings.maximum;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ton maximum habituel",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          "Le nombre de cigarettes que tu fumes un jour ordinaire.",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton.outlined(
              key: const Key("max-minus-btn"),
              tooltip: "Diminuer le maximum",
              onPressed: value > Settings.minMaximum
                  ? () => onChanged(settings.copyWith(maximum: value - 1))
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: Semantics(
                label: "Maximum",
                value: "$value par jour",
                child: Slider(
                  key: const Key("max-slider"),
                  value: value.toDouble(),
                  min: Settings.minMaximum.toDouble(),
                  max: Settings.maxMaximum.toDouble(),
                  divisions: Settings.maxMaximum - Settings.minMaximum,
                  label: "$value",
                  onChanged: (v) =>
                      onChanged(settings.copyWith(maximum: v.round())),
                ),
              ),
            ),
            IconButton.outlined(
              key: const Key("max-plus-btn"),
              tooltip: "Augmenter le maximum",
              onPressed: value < Settings.maxMaximum
                  ? () => onChanged(settings.copyWith(maximum: value + 1))
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        Center(
          child: Text(
            "$value par jour",
            key: const Key("max-value"),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class ModeField extends StatelessWidget {
  const ModeField({super.key, required this.settings, required this.onChanged});

  final Settings settings;
  final ValueChanged<Settings> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Type de tirage", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<QuotaMode>(
            key: const Key("mode-segments"),
            segments: [
              for (final mode in QuotaMode.values)
                ButtonSegment(value: mode, label: Text(mode.label)),
            ],
            selected: {settings.quotaMode},
            onSelectionChanged: (s) =>
                onChanged(settings.copyWith(quotaMode: s.single)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          settings.quotaMode.description,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (settings.quotaMode == QuotaMode.guided) ...[
          const SizedBox(height: 16),
          Text("Allure", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ReductionPace>(
              key: const Key("pace-segments"),
              segments: [
                for (final pace in ReductionPace.values)
                  ButtonSegment(value: pace, label: Text(pace.label)),
              ],
              selected: {settings.pace},
              onSelectionChanged: (s) =>
                  onChanged(settings.copyWith(pace: s.single)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            settings.pace.description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class DrawPolicyField extends StatelessWidget {
  const DrawPolicyField({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final Settings settings;
  final ValueChanged<Settings> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quota du jour", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<DrawPolicy>(
            key: const Key("policy-segments"),
            segments: [
              for (final policy in DrawPolicy.values)
                ButtonSegment(value: policy, label: Text(policy.label)),
            ],
            selected: {settings.drawPolicy},
            onSelectionChanged: (s) =>
                onChanged(settings.copyWith(drawPolicy: s.single)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          settings.drawPolicy.description,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class NotificationField extends StatelessWidget {
  const NotificationField({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final Settings settings;
  final ValueChanged<Settings> onChanged;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(
      hour: settings.notificationHour,
      minute: settings.notificationMinute,
    );
    return Column(
      children: [
        SwitchListTile(
          key: const Key("notif-switch"),
          contentPadding: EdgeInsets.zero,
          title: const Text("Rappel chaque matin"),
          subtitle: const Text("Une notification avec ton quota du jour."),
          value: settings.notificationsEnabled,
          onChanged: (v) =>
              onChanged(settings.copyWith(notificationsEnabled: v)),
        ),
        if (settings.notificationsEnabled)
          ListTile(
            key: const Key("notif-time-tile"),
            contentPadding: EdgeInsets.zero,
            title: const Text("Heure du rappel"),
            trailing: Text(
              time.format(context),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (picked != null) {
                onChanged(
                  settings.copyWith(
                    notificationHour: picked.hour,
                    notificationMinute: picked.minute,
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}
