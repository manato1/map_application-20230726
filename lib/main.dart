import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_application_20230726/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'オウンマップ',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}


