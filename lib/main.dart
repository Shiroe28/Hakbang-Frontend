import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/user_provider.dart';
import 'services/storage_service.dart';
import 'config/network_config.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Print network configuration for debugging
  NetworkConfig.printConfig();

  // Create UserProvider
  final userProvider = UserProvider();

  // Load user if token exists (so user data is available from app start)
  final token = await StorageService.getToken();
  if (token != null) {
    try {
      await userProvider.loadCurrentUser();
      print('✅ User loaded on app start: ${userProvider.user?.username}');
    } catch (e) {
      print('⚠️ Failed to load user on start: $e');
    }
  }

  runApp(HakbangApp(userProvider: userProvider));
}

class HakbangApp extends StatelessWidget {
  final UserProvider userProvider;

  const HakbangApp({super.key, required this.userProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: userProvider,
      child: MaterialApp(
        title: 'Hakbang',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF2c6894),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2c6894),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Color(0xFF2c6894),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2c6894),
              foregroundColor: Colors.white,
              elevation: 2,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2c6894), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
