
import 'package:elder_care/presentation/screens/splash_screen.dart';
import 'package:elder_care/utils/bindings.dart';
import 'package:elder_care/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'old_ui/old_login.dart';

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
      title: 'DashSocial',
      initialBinding: InitialBinding(),
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      home:SplashScreen(),
    );
  }
}


