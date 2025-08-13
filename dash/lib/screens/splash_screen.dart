import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import 'profile_screen.dart';
import 'map_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1200), () {
      final activeId = ref.read(activeProfileIdProvider);
      if (activeId == null) {
        Navigator.of(context).pushReplacementNamed(ProfileScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Dash', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
      ),
    );
  }
}