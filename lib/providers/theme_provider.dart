import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Theme mode provider: light/dark
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
