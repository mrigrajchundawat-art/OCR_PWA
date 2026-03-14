import 'package:flutter/material.dart';

import 'screens/ocr_screen.dart';

void main() {
  runApp(const OcrApp());
}

class OcrApp extends StatelessWidget {
  const OcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF238636),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const OcrScreen(),
    );
  }
}
