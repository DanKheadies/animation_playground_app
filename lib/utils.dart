import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';

List<Color> colors = [
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
  Colors.pink,
  Colors.orange,
  Colors.yellow,
  Colors.greenAccent,
  Colors.green,
];

const fullAngleInRadians = math.pi * 2;

double normalize(double value, double max) => (value % max + max) % max;

double normalizeAngle(double angle) => normalize(angle, fullAngleInRadians);

double toAngle(Offset position, Offset center) => (position - center).direction;

double toRadian(double value) => (value * math.pi) / 180;

Offset toPolar(Offset center, double radians, double radius) =>
    center + Offset.fromDirection(radians, radius);

/// Re-maps a number from one range to another
/// See map Function in processing https://processing.org/reference/map_.html
/// https://stackoverflow.com/a/5735770/10835183
double rangeMap(
  double x,
  double inMin,
  double inMax,
  double outMin,
  double outMax,
) {
  return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

double doubleInRange(num start, num end) =>
    Random().nextDouble() * (end - start) + start;
