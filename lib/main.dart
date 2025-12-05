import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:timezone/data/latest.dart' as tz;


import 'auth_guardian.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inicializar Timezones

  tz.initializeTimeZones();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenLife',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      home: const AuthGuardian(),
    );
  }
}