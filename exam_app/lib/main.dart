import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/statistics_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/storage_service.dart';
import 'core/navigation/route_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService().initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: MaterialApp(
        title: 'Strexam',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          ErrorClearingNavigatorObserver(),
        ],
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isAuthenticated ? HomeScreen() : LoginScreen();
          },
        ),
      ),
    );
  }
}
