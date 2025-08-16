import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freelago/router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'FreelaGo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          background: Colors.white,
          primary: Colors.black,
          secondary: Colors.grey.shade200,
          tertiary: Colors.grey.shade800,
        ),
        useMaterial3: true,
      ),
    );
  }
}
