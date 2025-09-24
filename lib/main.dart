import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (optional for mock mode)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue with mock data if Firebase fails
  }
  
  runApp(
    const ProviderScope(
      child: PayrollApp(),
    ),
  );
}