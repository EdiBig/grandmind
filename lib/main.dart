import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'firebase_options.dart';
import 'features/notifications/data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize timezone database
  tz.initializeTimeZones();

  // Initialize notification service
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: GrandMindApp(),
    ),
  );
}
