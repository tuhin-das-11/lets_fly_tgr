import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/config/env_config.dart';

/// Application entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Cloud SDK if configured
  if (EnvConfig.isConfigured) {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
      debug: false,
    );
  }

  runApp(
    const ProviderScope(
      child: LetsFlyTgrApp(),
    ),
  );
}
