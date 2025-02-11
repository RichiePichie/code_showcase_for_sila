import 'package:hive/hive.dart';

import 'workout/workout.dart';

part 'mesocycle.g.dart';

@HiveType(typeId: 3)
class Mesocycle extends HiveObject {
  @HiveField(0)
  final String mesocycleName;
  @HiveField(1)
  final List<Workout> workouts;
  @HiveField(2)
  int? durationInWeeks;
  Mesocycle({
    required this.mesocycleName,
    required this.workouts,
    required this.durationInWeeks,
  });

  @override
  String toString() {
    return '$mesocycleName - $workouts - $durationInWeeks weeks';
  }
}
