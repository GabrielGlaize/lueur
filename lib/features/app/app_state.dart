import "package:equatable/equatable.dart";

import "../../domain/settings.dart";

sealed class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

class AppLoading extends AppState {
  const AppLoading();
}

class AppNeedsOnboarding extends AppState {
  const AppNeedsOnboarding();
}

class AppReady extends AppState {
  const AppReady(this.settings);

  final Settings settings;

  @override
  List<Object?> get props => [settings];
}

/// Stored data could not be read; the user may reset it.
class AppStorageCorrupted extends AppState {
  const AppStorageCorrupted();
}
