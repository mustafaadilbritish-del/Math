import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'map_screen.dart';
import '../utils/responsive.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      // Profiles are optional; go straight to map if none.
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Dash',
          style: TextStyle(fontSize: scaledFontSize(context, baseOnPhone: 36, maxOnDesktop: 64), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}