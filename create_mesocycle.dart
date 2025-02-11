import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rich_pich/data/mesocycle/mesocycle.dart';
import 'package:rich_pich/data/mesocycle/workout/workout.dart';

import '../create_workout/create_workout.dart';
import '../workout_detail_view/detailed_view.dart';

class CreateMesocycle extends StatefulWidget {
  const CreateMesocycle({super.key});

  @override
  State<CreateMesocycle> createState() => _CreateMesocycleState();
}

class _CreateMesocycleState extends State<CreateMesocycle> {
  final workoutBox = Hive.box<Workout>('workout');
  final mesocycleBox = Hive.box<Mesocycle>('mesocycle');
  final TextEditingController _mesocycleName = TextEditingController();
  int? _selectedDuration;

  @override
  void dispose() {
    _mesocycleName.dispose();
    super.dispose();
  }

  void addWorkout() {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CreateWorkout()))
        .then((_) {
      setState(() {});
    });
  }

  void saveMesocycle() async {
    if (_mesocycleName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a mesocycle name')),
      );
      return;
    }

    if (_selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a duration')),
      );
      return;
    }

    if (workoutBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one workout')),
      );
      return;
    }

    try {
      final mesocycle = Mesocycle(
        mesocycleName: _mesocycleName.text,
        workouts: workoutBox.values.toList(),
        durationInWeeks: _selectedDuration!,
      );

      await mesocycleBox.add(mesocycle);

      await workoutBox.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Mesocycle "${_mesocycleName.text}" created successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating mesocycle: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextField(
          controller: _mesocycleName,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: 'Mesocycle Name'),
        ),
      ),
      body: Column(
        children: [
          // Duration selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [4, 5, 6].map((weeks) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text('$weeks weeks'),
                    selected: _selectedDuration == weeks,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDuration = selected ? weeks : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          // Workout list
          Expanded(
            child: workoutBox.isEmpty
                ? const Center(child: Text('No workouts added yet'))
                : ListView.builder(
                    itemCount: workoutBox.values.length,
                    itemBuilder: (context, index) => WorkoutWidget(
                      workout: workoutBox.values.toList()[index],
                    ),
                  ),
          ),
          // Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextButton(
                  onPressed: addWorkout,
                  child: const Text('Add Workout'),
                ),
                TextButton(
                  onPressed: saveMesocycle,
                  child: const Text('Create Mesocycle'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutWidget extends StatelessWidget {
  final Workout workout;
  const WorkoutWidget({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedView(workout: workout),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: 50,
        color: const Color.fromARGB(255, 65, 66, 66),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  workout.date.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  workout.workoutName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (workout.exercises.length > 1)
                  Text(
                    '${workout.exercises.length} exercises',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                if (workout.exercises.length == 1)
                  Text(
                    '${workout.exercises.length} exercise',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
