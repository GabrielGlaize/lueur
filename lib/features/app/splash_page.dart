import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../core/widgets/lueur_logo.dart";
import "app_cubit.dart";
import "app_state.dart";

/// Shown while storage loads, or when it cannot be read.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                if (state is AppStorageCorrupted) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Tes données enregistrées sont illisibles. Tu peux repartir de zéro : cela efface l’historique et les réglages de ce téléphone.",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        key: const Key("splash-reset-btn"),
                        onPressed: () =>
                            context.read<AppCubit>().resetEverything(),
                        child: const Text("Repartir de zéro"),
                      ),
                    ],
                  );
                }
                return const LueurLogo(size: 96);
              },
            ),
          ),
        ),
      ),
    );
  }
}
