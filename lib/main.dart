import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/medicine_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService().initializeNotifications();
  
  // Initialize settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();
  
  // Initialize profile
  final profileProvider = ProfileProvider();
  await profileProvider.init();
  
  runApp(MyApp(
    settingsProvider: settingsProvider,
    profileProvider: profileProvider,
  ));
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final ProfileProvider profileProvider;

  const MyApp({
    super.key,
    required this.settingsProvider,
    required this.profileProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: profileProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Medicine Reminder',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
              ),
              scaffoldBackgroundColor: AppColors.background,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}