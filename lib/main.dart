// ignore_for_file: unused_import

import 'package:flutter/material.dart';

import 'front.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Easy Weigh',
      home: FrontPesagens(),
    );
  }
}
