import "package:flutter_bloc/flutter_bloc.dart";

import "../../core/dates.dart";
import "../../core/log.dart";
import "../../data/storage_exception.dart";
import "../../domain/day_record.dart";
import "../../domain/settings.dart";
import "../../services/day_planner.dart";
import "home_state.dart";

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required DayPlanner planner,
    required Clock clock,
    required Settings Function() settings,
  }) : _planner = planner,
       _clock = clock,
       _settings = settings,
       super(const HomeLoading());

  final DayPlanner _planner;
  final Clock _clock;
  final Settings Function() _settings;

  /// Reloads the day, for first display, return from background or a new day.
  Future<void> refresh() => _run(() => _planner.plan(_settings()));

  Future<void> addCigarette() => _run(() => _planner.adjustToday(1));

  Future<void> undoCigarette() => _run(() => _planner.adjustToday(-1));

  Future<void> _run(Future<Map<String, DayRecord>> Function() action) async {
    try {
      final days = await action();
      final today = dayStart(_clock());
      emit(
        HomeReady(
          today: days[dateKeyOf(today)]!,
          week: [
            for (var back = 6; back >= 0; back--)
              _seen(days[dateKeyOf(addDays(today, -back))]),
          ],
          settings: _settings(),
        ),
      );
    } on StorageCorruptedException catch (error) {
      logger.e("Home could not read storage", error: error);
      emit(const HomeFailure());
    }
  }

  DayRecord? _seen(DayRecord? record) =>
      record != null && record.seen ? record : null;
}
