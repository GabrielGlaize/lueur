import "package:equatable/equatable.dart";

import "../../domain/day_record.dart";
import "../../domain/settings.dart";

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeReady extends HomeState {
  const HomeReady({
    required this.today,
    required this.week,
    required this.settings,
  });

  final DayRecord today;

  /// The last seven calendar days, oldest first, today last. A null slot is a
  /// day the app was not opened, so nothing is known about it.
  final List<DayRecord?> week;
  final Settings settings;

  @override
  List<Object?> get props => [today, week, settings];
}

class HomeFailure extends HomeState {
  const HomeFailure();
}
