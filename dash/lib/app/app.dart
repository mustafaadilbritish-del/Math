import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../screens/splash_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/map_screen.dart';
import '../screens/lesson_screen.dart';

class DashApp extends ConsumerWidget {
  const DashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(appInitializationProvider);

    return MaterialApp(
      title: 'Dash - Times Tables',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 1.1),
      ),
      debugShowCheckedModeBanner: false,
      home: initialization.when(
        data: (_) => const SplashScreen(),
        loading: () => const SplashScreen(),
        error: (e, st) => Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
      ),
      routes: {
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        MapScreen.routeName: (_) => const MapScreen(),
        LessonScreen.routeName: (_) => const LessonScreen(),
      },
    );
  }
}