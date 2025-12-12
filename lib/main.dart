
import 'package:elder_care/modules/splash/views/splash_screen.dart';
import 'package:elder_care/core/bindings/bindings.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/utils/constants.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: constants.supabaseUrl,
    anonKey: constants.supabaseKey,
  );

  runApp(
      MyApp());
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


