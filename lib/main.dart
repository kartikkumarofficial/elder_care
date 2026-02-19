
import 'package:elder_care/modules/splash/views/splash_screen.dart';
import 'package:elder_care/core/bindings/bindings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/utils/constants.dart';
import 'core/app_lifecycle_handler.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (Firebase.apps.isEmpty) {

  // }

  await Supabase.initialize(
    url: constants.supabaseUrl,
    anonKey: constants.supabaseKey,
  );

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Elder Care',
      initialBinding: InitialBinding(),
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      debugShowCheckedModeBanner: false,
      home:SplashScreen(),
    );
  }
}



