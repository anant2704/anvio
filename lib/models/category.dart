// 📂 anvio/lib/models/category.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late int iconCodepoint;

  @HiveField(2)
  late int colorValue;

  Category({
    required this.name,
    required this.iconCodepoint,
    required this.colorValue,
  });

  IconData get icon => IconData(iconCodepoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  @override
  bool operator ==(Object other) => other is Category && other.name == name;

  @override
  int get hashCode => name.hashCode;
}