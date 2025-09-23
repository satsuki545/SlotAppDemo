// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/slot/presentation/slot_screen.dart';

void main() {
  runApp(const SlotApp());
}

// app.dart
class SlotApp extends StatelessWidget {
  const SlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: const SlotScreen(),
      ),
    );
  }
}