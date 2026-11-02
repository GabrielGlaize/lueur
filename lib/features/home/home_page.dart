import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../../core/dates.dart";
import "../../core/widgets/lueur_logo.dart";
import "../../domain/day_record.dart";
import "../../domain/quota_copy.dart";
import "../app/app_cubit.dart";
import "../app/app_state.dart";
import "home_cubit.dart";
import "home_state.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      // After a reset the app leaves Ready; the home page is about to go away.
      listenWhen: (_, current) => current is AppReady,
      listener: (context, state) => context.read<HomeCubit>().refresh(),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              LueurLogo(size: 30),
              SizedBox(width: 10),
              Text("Lueur", style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          actions: [
            IconButton(
              key: const Key("home-about-btn"),
              tooltip: "À propos et aide",
              onPressed: () => context.push("/about"),
              icon: const Icon(Icons.info_outline),
            ),
            IconButton(
              key: const Key("home-settings-btn"),
              tooltip: "Réglages",
              onPressed: () => context.push("/settings"),
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) => switch (state) {
              HomeLoading() => const Center(child: CircularProgressIndicator()),
              HomeFailure() => const _HomeFailure(),
              HomeReady() => _HomeContent(state: state),
            },
          ),
        ),
      ),
    );
  }
}

class _HomeFailure extends StatelessWidget {
  const _HomeFailure();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Impossible de lire tes données.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key("home-retry-btn"),
            onPressed: () => context.read<HomeCubit>().refresh(),
            child: const Text("Réessayer"),
          ),
        ],
      ),
    ),
  );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final HomeReady state;

  @override
  Widget build(BuildContext context) {
    final today = state.today;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          QuotaCopy.dayMessage(today.quota, state.settings.maximum),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        _QuotaRing(record: today),
        const SizedBox(height: 24),
        Semantics(
          liveRegion: true,
          child: Text(
            QuotaCopy.statusMessage(today.smoked, today.quota),
            key: const Key("home-status"),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const Key("home-add-btn"),
          onPressed: today.smoked >= DayRecord.maxSmoked
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  context.read<HomeCubit>().addCigarette();
                },
          icon: const Icon(Icons.add),
          label: const Text("J’ai fumé une cigarette"),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const Key("home-undo-btn"),
          onPressed: today.smoked == 0
              ? null
              : () => context.read<HomeCubit>().undoCigarette(),
          icon: const Icon(Icons.undo),
          label: const Text("Annuler la dernière"),
        ),
        const SizedBox(height: 32),
        Text("7 derniers jours", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _WeekCard(week: state.week),
      ],
    );
  }
}

class _QuotaRing extends StatelessWidget {
  const _QuotaRing({required this.record});

  final DayRecord record;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final over = record.smoked > record.quota;
    final progress = record.quota == 0
        ? (record.smoked > 0 ? 1.0 : 0.0)
        : (record.smoked / record.quota).clamp(0.0, 1.0);
    return Semantics(
      label:
          "Aujourd’hui, ${QuotaCopy.cigarettes(record.smoked)} fumée"
          "${record.smoked > 1 ? "s" : ""} sur un quota de ${record.quota}.",
      child: ExcludeSemantics(
        child: Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress,
                track: scheme.outline,
                fill: over ? scheme.error : scheme.primary,
              ),
              child: Padding(
                padding: const EdgeInsets.all(36),
                // The ring has a fixed size, so large text scales down inside it.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${record.quota}",
                        key: const Key("home-quota"),
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        "quota du jour",
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${record.smoked} fumée${record.smoked > 1 ? "s" : ""}",
                        key: const Key("home-smoked"),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width / 2 - stroke,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        paint..color = fill,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track || old.fill != fill;
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.week});

  final List<DayRecord?> week;

  static const _weekdays = ["lun", "mar", "mer", "jeu", "ven", "sam", "dim"];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final record in week.reversed)
              if (record != null) _WeekRow(record: record),
            if (week.every((record) => record == null))
              const Text("Rien à afficher pour l’instant."),
          ],
        ),
      ),
    );
  }

  static String label(DayRecord record) {
    final date = DateTime.parse(record.dateKey);
    return "${_weekdays[date.weekday - 1]} ${date.day}";
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.record});

  final DayRecord record;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isToday = record.dateKey == dateKeyOf(DateTime.now());
    final verdict = record.respected ? "dans le quota" : "quota dépassé";
    return Semantics(
      label:
          "${_WeekCard.label(record)} : ${record.smoked} sur ${record.quota}, "
          "$verdict",
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  isToday ? "aujourd’hui" : _WeekCard.label(record),
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
              Expanded(
                child: Text(
                  "${record.smoked} / ${record.quota}",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Icon(
                record.respected ? Icons.check_circle_outline : Icons.circle,
                size: 20,
                color: record.respected ? scheme.primary : scheme.error,
              ),
              const SizedBox(width: 6),
              Text(verdict, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
