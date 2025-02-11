import 'package:flutter/material.dart';
import 'package:rich_pich/data/mesocycle/workout/workout.dart';
import 'package:rich_pich/mesocycle/workout_detail_view/custom_kebab_menu/custom_kebab_menu.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/mesocycle/workout/exercise_set.dart';

import '../../data/mesocycle/workout/exercise.dart';

class SetData {
  final TextEditingController weightController;
  final TextEditingController repsController;
  bool isLogged;

  SetData({
    required this.weightController,
    required this.repsController,
    this.isLogged = false,
  });

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}

class DetailedView extends StatefulWidget {
  final Workout workout;
  const DetailedView({super.key, required this.workout});

  @override
  State<DetailedView> createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView> {
  late Box<Exercise> exerciseBox;
  late Box<Workout> workoutBox;

  Map<int, List<SetData>> exerciseSets = {};

  @override
  void initState() {
    super.initState();
    exerciseBox = Hive.box<Exercise>('exercise');
    workoutBox = Hive.box<Workout>('workout');
    _loadExistingSets();
  }

  void _loadExistingSets() {
    for (int i = 0; i < widget.workout.exercises.length; i++) {
      final exercise = widget.workout.exercises[i];
      if (exercise.exerciseSets != null && exercise.exerciseSets!.isNotEmpty) {
        exerciseSets[i] = exercise.exerciseSets!
            .map((set) => SetData(
                  weightController:
                      TextEditingController(text: set.weight.toString()),
                  repsController:
                      TextEditingController(text: set.reps.toString()),
                  isLogged: set.isChecked,
                ))
            .toList();
      } else {
        exerciseSets[i] = [
          SetData(
            weightController: TextEditingController(),
            repsController: TextEditingController(),
          )
        ];
      }
    }
  }

  void addSet(int exerciseIndex) {
    setState(() {
      exerciseSets[exerciseIndex]?.add(
        SetData(
          weightController: TextEditingController(),
          repsController: TextEditingController(),
        ),
      );
    });
  }

  void removeSet(int exerciseIndex) {
    if ((exerciseSets[exerciseIndex]?.length ?? 0) > 1) {
      setState(() {
        exerciseSets[exerciseIndex]?.last.dispose();
        exerciseSets[exerciseIndex]?.removeLast();
      });
    }
  }

  @override
  void dispose() {
    for (var sets in exerciseSets.values) {
      for (var set in sets) {
        set.dispose();
      }
    }
    super.dispose();
  }

  Future<void> saveWorkoutData() async {
    try {
      if (!workoutBox.values.contains(widget.workout)) {
        await workoutBox.add(widget.workout);
      }

      for (int i = 0; i < widget.workout.exercises.length; i++) {
        final exercise = widget.workout.exercises[i];

        if (!exerciseBox.values.contains(exercise)) {
          await exerciseBox.add(exercise);
        }

        final sets = exerciseSets[i]!
            .map((setData) => ExerciseSet(
                  weight: double.tryParse(setData.weightController.text) ?? 0.0,
                  reps: int.tryParse(setData.repsController.text) ?? 0,
                  isChecked: setData.isLogged,
                ))
            .toList();

        exercise.exerciseSets = sets;
        await exercise.save();
      }

      await widget.workout.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout data saved successfully')),
      );
    } catch (e) {
      print('Error saving workout data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving workout data: $e')),
      );
    }
  }

  void addExerciseNote(int exerciseIndex, String newNote) {
    setState(() {
      widget.workout.exercises[exerciseIndex].exerciseNote = newNote;
    });
  }

  void showNoteDialog(int exerciseIndex) {
    TextEditingController exerciseNote = TextEditingController(
        text: widget.workout.exercises[exerciseIndex].exerciseNote);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Exercise Note'),
            content: TextField(
              maxLength: 45,
              controller: exerciseNote,
              decoration: InputDecoration(
                hintText: 'Your Notes to This Exercise',
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    addExerciseNote(exerciseIndex, exerciseNote.text);
                    Navigator.pop(context);
                  },
                  child: Text('Save'))
            ],
          );
        });
  }

  void replaceExercise(int exerciseIndex) {
    TextEditingController newExerciseName = TextEditingController();
    TextEditingController newMuscleGroup = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Replace Exercise'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                      hintText:
                          widget.workout.exercises[exerciseIndex].muscleGroup),
                  controller: newMuscleGroup,
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText:
                          widget.workout.exercises[exerciseIndex].exerciseName),
                  controller: newExerciseName,
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    setState(() {
                      widget.workout.exercises[exerciseIndex].exerciseName =
                          newExerciseName.text;

                      widget.workout.exercises[exerciseIndex].muscleGroup =
                          newMuscleGroup.text;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Save')),
            ],
          );
        });
  }

  void deleteExercise(int exerciseIndex) {
    setState(() {
      widget.workout.exercises.removeAt(exerciseIndex);
      if (widget.workout.isInBox) {
        widget.workout.save();
      }
      if (widget.workout.exercises[exerciseIndex].isInBox != true) {
        widget.workout.delete();
        Navigator.pop(context);
      }
    });
  }

  bool allSetsChecked(int exerciseIndex) {
    if (widget.workout.exercises[exerciseIndex].exerciseSets == null ||
        widget.workout.exercises[exerciseIndex].exerciseSets!.isEmpty) {
      return false;
    }
    return widget.workout.exercises[exerciseIndex].exerciseSets!
        .every((set) => set.isChecked);
  }

  bool allExercisesAreChecked() {
    return widget.workout.exercises.every(
        (exercise) => exercise.exerciseSets!.every((set) => set.isChecked));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.workout.workoutName,
              ),
              SizedBox(
                width: 30,
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.workout.exercises.length,
                itemBuilder: (context, exerciseIndex) {
                  final exercise = widget.workout.exercises[exerciseIndex];
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: const Color.fromARGB(118, 54, 51, 51),
                                blurRadius: 2,
                                spreadRadius: 2)
                          ],
                          color: const Color.fromARGB(255, 27, 26, 26),
                        ),
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  exercise.exerciseName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                CustomKebabMenu(
                                  onAddSet: () => addSet(exerciseIndex),
                                  onRemoveSet: () => removeSet(exerciseIndex),
                                  onAddExerciseNote: () =>
                                      showNoteDialog(exerciseIndex),
                                  onReplaceExercise: () =>
                                      replaceExercise(exerciseIndex),
                                  onDeleteExercise: () =>
                                      deleteExercise(exerciseIndex),
                                ),
                              ],
                            ),
                            if (widget.workout.exercises[exerciseIndex]
                                    .exerciseNote !=
                                null)
                              Container(
                                color: const Color.fromARGB(234, 199, 163, 31),
                                width: MediaQuery.of(context).size.width * 0.85,
                                height: 30,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Icon(Icons.edit_note),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      widget.workout.exercises[exerciseIndex]
                                          .exerciseNote!,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('WEIGHT'),
                                Text('REPS'),
                                Text('LOG'),
                              ],
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  exerciseSets[exerciseIndex]?.length ?? 0,
                              itemBuilder: (context, setIndex) {
                                final setData =
                                    exerciseSets[exerciseIndex]![setIndex];
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: TextField(
                                        controller: setData.weightController,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            hintText: '0.0'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: TextField(
                                        controller: setData.repsController,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            hintText: '0'),
                                      ),
                                    ),
                                    Checkbox(
                                      value: setData.isLogged,
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            setData.isLogged = value!;
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 3,
                        left: 40,
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(221, 24, 23, 23),
                              border: Border.all(color: Colors.red)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                exercise.muscleGroup,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: saveWorkoutData,
          child: const Text('Save'),
        ),
      ),
    );
  }
}
