import '../models/category.dart';
import '../models/exercise.dart';
import '../models/enums.dart';
import 'repository.dart';

class FixtureData {
  /// Load initial fixture data for fresh installs
  static Future<void> loadFixtureData(Repository repository) async {
    // Check if data already exists
    final existingCategories = repository.getAllCategories();
    if (existingCategories.isNotEmpty) {
      return; // Data already loaded
    }

    // Create categories with muscle group classifications
    final categories = [
      // Large muscle groups
      Category(
        id: 'chest',
        name: 'Chest',
        group: ExerciseCategoryGroup.largeMuscleGroup,
      ),
      Category(
        id: 'back',
        name: 'Back',
        group: ExerciseCategoryGroup.largeMuscleGroup,
      ),
      Category(
        id: 'legs',
        name: 'Legs',
        group: ExerciseCategoryGroup.largeMuscleGroup,
      ),
      Category(
        id: 'shoulders',
        name: 'Shoulders',
        group: ExerciseCategoryGroup.largeMuscleGroup,
      ),
      Category(
        id: 'functional',
        name: 'Functional / HYROX',
        group: ExerciseCategoryGroup.largeMuscleGroup,
      ),
      Category(
        id: 'carries',
        name: 'Carries & Grip',
        group: ExerciseCategoryGroup.largeMuscleGroup,
      ),

      // Small muscle groups
      Category(
        id: 'biceps',
        name: 'Biceps',
        group: ExerciseCategoryGroup.smallMuscleGroup,
      ),
      Category(
        id: 'triceps',
        name: 'Triceps',
        group: ExerciseCategoryGroup.smallMuscleGroup,
      ),
      Category(
        id: 'abs',
        name: 'Abs',
        group: ExerciseCategoryGroup.smallMuscleGroup,
      ),
      Category(
        id: 'calves',
        name: 'Calves',
        group: ExerciseCategoryGroup.smallMuscleGroup,
      ),
    ];

    // Save categories
    for (final category in categories) {
      await repository.saveCategory(category);
    }

    // Create exercises - HYROX focused
    final exercises = [
      // Chest exercises
      Exercise(id: 'bench_press', name: 'Bench Press', categoryId: 'chest'),
      Exercise(id: 'incline_bench_press', name: 'Incline Bench Press', categoryId: 'chest'),
      Exercise(id: 'dumbbell_press', name: 'Dumbbell Press', categoryId: 'chest'),
      Exercise(id: 'push_ups', name: 'Push-ups', categoryId: 'chest', isBodyweight: true),
      Exercise(id: 'chest_fly', name: 'Chest Fly', categoryId: 'chest'),

      // Back exercises
      Exercise(id: 'deadlift', name: 'Deadlift', categoryId: 'back'),
      Exercise(id: 'pull_ups', name: 'Pull-ups', categoryId: 'back', isBodyweight: true),
      Exercise(id: 'bent_over_row', name: 'Bent Over Row', categoryId: 'back'),
      Exercise(id: 'lat_pulldown', name: 'Lat Pulldown', categoryId: 'back'),
      Exercise(id: 'seated_cable_row', name: 'Seated Cable Row', categoryId: 'back'),
      Exercise(id: 'romanian_deadlift', name: 'Romanian Deadlift', categoryId: 'back'),
      Exercise(id: 'single_arm_row', name: 'Single Arm Row', categoryId: 'back'),

      // Leg exercises
      Exercise(id: 'squat', name: 'Squat', categoryId: 'legs'),
      Exercise(id: 'front_squat', name: 'Front Squat', categoryId: 'legs'),
      Exercise(id: 'goblet_squat', name: 'Goblet Squat', categoryId: 'legs'),
      Exercise(id: 'leg_press', name: 'Leg Press', categoryId: 'legs'),
      Exercise(id: 'lunges', name: 'Lunges', categoryId: 'legs'),
      Exercise(id: 'walking_lunges', name: 'Walking Lunges', categoryId: 'legs'),
      Exercise(id: 'leg_curls', name: 'Leg Curls', categoryId: 'legs'),
      Exercise(id: 'leg_extensions', name: 'Leg Extensions', categoryId: 'legs'),
      Exercise(id: 'bulgarian_split_squat', name: 'Bulgarian Split Squat', categoryId: 'legs'),
      Exercise(id: 'step_ups', name: 'Step Ups', categoryId: 'legs'),

      // Shoulder exercises
      Exercise(id: 'overhead_press', name: 'Overhead Press', categoryId: 'shoulders'),
      Exercise(id: 'lateral_raises', name: 'Lateral Raises', categoryId: 'shoulders'),
      Exercise(id: 'front_raises', name: 'Front Raises', categoryId: 'shoulders'),
      Exercise(id: 'rear_delt_fly', name: 'Rear Delt Fly', categoryId: 'shoulders'),
      Exercise(id: 'face_pulls', name: 'Face Pulls', categoryId: 'shoulders'),

      // Functional / HYROX exercises
      Exercise(id: 'sled_push', name: 'Sled Push', categoryId: 'functional'),
      Exercise(id: 'sled_pull', name: 'Sled Pull', categoryId: 'functional'),
      Exercise(id: 'wall_balls', name: 'Wall Balls', categoryId: 'functional'),
      Exercise(id: 'burpee_broadjump', name: 'Burpee Broadjump', categoryId: 'functional', isBodyweight: true),
      Exercise(id: 'ski_erg', name: 'Ski Erg', categoryId: 'functional'),
      Exercise(id: 'row_erg', name: 'Row Erg', categoryId: 'functional'),
      Exercise(id: 'box_jumps', name: 'Box Jumps', categoryId: 'functional', isBodyweight: true),
      Exercise(id: 'battle_ropes', name: 'Battle Ropes', categoryId: 'functional'),
      Exercise(id: 'kettlebell_swings', name: 'Kettlebell Swings', categoryId: 'functional'),
      Exercise(id: 'thrusters', name: 'Thrusters', categoryId: 'functional'),

      // Carries & Grip exercises (HYROX focus)
      Exercise(id: 'sandbag_carry', name: 'Sandbag Carry', categoryId: 'carries'),
      Exercise(id: 'sandbag_lunges', name: 'Sandbag Lunges', categoryId: 'carries'),
      Exercise(id: 'farmer_carry', name: 'Farmer Carry', categoryId: 'carries'),
      Exercise(id: 'suitcase_carry', name: 'Suitcase Carry', categoryId: 'carries'),
      Exercise(id: 'overhead_carry', name: 'Overhead Carry', categoryId: 'carries'),
      Exercise(id: 'dead_hang', name: 'Dead Hang', categoryId: 'carries', isBodyweight: true),
      Exercise(id: 'plate_pinch', name: 'Plate Pinch Hold', categoryId: 'carries'),

      // Bicep exercises
      Exercise(id: 'bicep_curls', name: 'Bicep Curls', categoryId: 'biceps'),
      Exercise(id: 'hammer_curls', name: 'Hammer Curls', categoryId: 'biceps'),
      Exercise(id: 'preacher_curls', name: 'Preacher Curls', categoryId: 'biceps'),

      // Tricep exercises
      Exercise(id: 'tricep_dips', name: 'Tricep Dips', categoryId: 'triceps', isBodyweight: true),
      Exercise(id: 'tricep_pushdowns', name: 'Tricep Pushdowns', categoryId: 'triceps'),
      Exercise(id: 'overhead_tricep_extension', name: 'Overhead Tricep Extension', categoryId: 'triceps'),

      // Ab exercises
      Exercise(id: 'sit_ups', name: 'Sit-ups', categoryId: 'abs', isBodyweight: true),
      Exercise(id: 'crunches', name: 'Crunches', categoryId: 'abs', isBodyweight: true),
      Exercise(id: 'plank', name: 'Plank', categoryId: 'abs', isBodyweight: true),
      Exercise(id: 'russian_twists', name: 'Russian Twists', categoryId: 'abs', isBodyweight: true),
      Exercise(id: 'leg_raises', name: 'Leg Raises', categoryId: 'abs', isBodyweight: true),
      Exercise(id: 'dead_bug', name: 'Dead Bug', categoryId: 'abs', isBodyweight: true),
      Exercise(id: 'pallof_press', name: 'Pallof Press', categoryId: 'abs'),

      // Calf exercises
      Exercise(id: 'calf_raises', name: 'Calf Raises', categoryId: 'calves'),
      Exercise(id: 'seated_calf_raises', name: 'Seated Calf Raises', categoryId: 'calves'),
    ];

    // Save exercises
    for (final exercise in exercises) {
      await repository.saveExercise(exercise);
    }
  }
}
