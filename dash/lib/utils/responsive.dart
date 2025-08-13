import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}

bool isPhone(BuildContext context) => MediaQuery.sizeOf(context).width < Breakpoints.tablet;
bool isTablet(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return w >= Breakpoints.tablet && w < Breakpoints.desktop;
}
bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

int gridCountForWidth(BuildContext context, {int phone = 3, int tablet = 4, int desktop = 6, int largeDesktop = 8}) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= Breakpoints.largeDesktop) return largeDesktop;
  if (w >= Breakpoints.desktop) return desktop;
  if (w >= Breakpoints.tablet) return tablet;
  return phone;
}

// Returns a font size that scales with width but is clamped between min and max
double scaledFontSize(BuildContext context, {required double baseOnPhone, required double maxOnDesktop}) {
  final w = MediaQuery.sizeOf(context).width;
  final t = (w - 320) / (Breakpoints.desktop - 320);
  final factor = t.clamp(0.0, 1.0);
  return lerpDouble(baseOnPhone, maxOnDesktop, factor) ?? baseOnPhone;
}

// Helper because dart:ui lerpDouble isn't accessible in widgets without import
double? lerpDouble(num? a, num? b, double t) {
  if (a == null && b == null) return null;
  a = a ?? 0.0;
  b = b ?? 0.0;
  return a + (b - a) * t;
}

// Constrain very wide layouts for readability
Widget constrainedBody({required Widget child, double maxWidth = 900}) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}