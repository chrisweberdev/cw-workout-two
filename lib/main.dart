import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// Models
import 'models/enums.dart';
import 'models/category.dart';
import 'models/exercise.dart';
import 'models/set_entry.dart';
import 'models/plan.dart';
import 'models/strength_session.dart';
import 'models/running_session.dart';
import 'models/hiit_session.dart';
import 'models/body_scan.dart';
import 'models/gpt_feedback.dart';
import 'models/app_settings.dart';

// Data & Services
import 'data/repository.dart';
import 'data/fixture_data.dart';
import 'theme/theme_manager.dart';

// UI
import 'ui/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive differently for web vs mobile
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDir.path);
  }

  // Register Hive adapters for enums
  Hive.registerAdapter(WorkoutTypeAdapter());
  Hive.registerAdapter(RunTypeAdapter());
  Hive.registerAdapter(SuggestionStatusAdapter());
  Hive.registerAdapter(ExerciseCategoryGroupAdapter());

  // Register Hive adapters for models
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(SetEntryAdapter());
  Hive.registerAdapter(PlanExerciseAdapter());
  Hive.registerAdapter(PlanAdapter());
  Hive.registerAdapter(ExerciseRecordAdapter());
  Hive.registerAdapter(StrengthSessionAdapter());
  Hive.registerAdapter(RunningSessionAdapter());
  Hive.registerAdapter(HiitSessionAdapter());
  Hive.registerAdapter(BodyScanAdapter());
  Hive.registerAdapter(ProgressionSuggestionAdapter());
  Hive.registerAdapter(GptFeedbackAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  // Initialize repository
  final repository = Repository();
  await repository.initialize();

  // Initialize theme manager
  final themeManager = ThemeManager();
  await themeManager.initialize();

  // Load fixture data for fresh installs
  await FixtureData.loadFixtureData(repository);

  runApp(MyApp(repository: repository, themeManager: themeManager));
}

class MyApp extends StatelessWidget {
  final Repository repository;
  final ThemeManager themeManager;

  const MyApp({
    super.key,
    required this.repository,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeManager>.value(value: themeManager),
        Provider<Repository>.value(value: repository),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CW Hybrid Training',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeManager.themeMode,
            home: const AppShell(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
        primary: const Color(0xFF6366F1),
        secondary: const Color(0xFF10B981),
        tertiary: const Color(0xFFF59E0B),
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.dark,
        primary: const Color(0xFF818CF8),
        secondary: const Color(0xFF34D399),
        tertiary: const Color(0xFFFBBF24),
        surface: const Color(0xFF1E1E1E),
        onSurface: const Color(0xFFE5E5E5),
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF1E1E1E),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
