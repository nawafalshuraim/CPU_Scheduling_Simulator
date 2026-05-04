import 'package:flutter/material.dart';
import 'screens/input_screen.dart';

void main() => runApp(const SchedulerApp());

class SchedulerApp extends StatelessWidget {
  const SchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPU Scheduling Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary:   Color(0xFF4F8EF7),
          secondary: Color(0xFF50C5A0),
          surface:   Color(0xFF252B3E),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1F2E),
        cardColor:               const Color(0xFF252B3E),
        inputDecorationTheme: InputDecorationTheme(
          filled:    true,
          fillColor: const Color(0xFF1A1F2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3A4A6B)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3A4A6B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF4F8EF7), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      home: const InputScreen(),
    );
  }
}
