import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapboxtrial/mapBoxMap.dart';
import 'package:mapboxtrial/searchScreen.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String secreteToken =
      "sk.eyJ1Ijoia2F5LWZsZXgxMiIsImEiOiJjbDU5bmM2cTkxMTRwM3BucnYza2Uxam0wIn0.6XDTbic5E4NIOnF4rsvPyw";

  // @override
  // void initState() {
  // print('this is the location ${location}');
  // }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MapBox Integration",
      home: SearchScreen(),
    );
  }
}
