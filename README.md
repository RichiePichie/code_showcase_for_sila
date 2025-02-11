# Workout Planning System
### *This code was provided from my project*

## Overview
A Flutter-based workout planning system that allows users to create and manage mesocycles (training blocks) with customizable workouts and exercises.
## Key Components

### CreateMesocycle (`create_mesocycle.dart`)
- Main interface for creating training blocks
- Handles workout collection and mesocycle duration
- Features:
  - Dynamic workout addition
  - Duration selection (4-6 weeks)
  - Validation and error handling
  - Persistent storage with Hive

### Mesocycle Model (`mesocycle.dart`)
- Data model for training blocks
- Implements Hive persistence
- Properties:
  - Mesocycle name
  - Workout collection
  - Duration in weeks

### DetailedView (`detailed_view.dart`)
- Detailed workout management interface
- Features:
  - Exercise logging
  - Set tracking
  - Exercise notes
  - Exercise customization
  - Real-time updates

## Technical Implementation

### State Management
- Uses StatefulWidget for local state
- Implements Hive for persistent storage
- Handles complex form validation

### Data Persistence
- Hive database integration
- Type adapters for custom objects
- Automatic data synchronization

### UI Components
- Custom widgets for exercise display
- Interactive set logging
- Dynamic form validation
- Error handling and user feedback

## Code Examples

### Creating a Mesocycle
```dart
final mesocycle = Mesocycle(
  mesocycleName: "Summer Strength",
  workouts: workoutsList,
  durationInWeeks: 6
);

