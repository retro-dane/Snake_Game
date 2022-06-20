import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_page.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAkGsgLp9eVInzpaGzn1-0WCfEHyLRUzHI",
        authDomain: "snake-game-95746.firebaseapp.com",
        projectId: "snake-game-95746",
        storageBucket: "snake-game-95746.appspot.com",
        messagingSenderId: "812045491843",
        appId: "1:812045491843:web:efa067238787c027d045b6",
        measurementId: "G-B5WSTGXM2W",),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePage(),
    );
  }
}