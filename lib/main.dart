import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/habit_model.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_habit_screen.dart';
import 'screens/edit_habit_screen.dart';
import 'constants/colors.dart';
import 'providers/habit_provider.dart';

void main() async {
  // Pastikan Flutter siap sebelum jalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapter untuk model Habit
  Hive.registerAdapter(HabitAdapter());

  // Buka Box (laci penyimpanan) untuk Habit
  await Hive.openBox<Habit>(habitBoxName);

  // Jalankan aplikasi
  runApp(
    // ProviderScope WAJIB untuk Riverpod!
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habitly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.lightBackground,
        textTheme: GoogleFonts.urbanistTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          background: AppColors.lightBackground,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/add-habit': (context) => const AddHabitScreen(),
        '/edit-habit': (context) => const EditHabitScreen(),
      },
    );
  }
}