import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final Color color;
  final IconData icon;
  final int itemCount;

  Category({
    this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.itemCount = 0,
  });

  Category copyWith({
    int? id,
    String? name,
    Color? color,
    IconData? icon,
    int? itemCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'itemCount': itemCount,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: Color(map['color']),
      icon: IconData(
        map['icon'],
        fontFamily: map['iconFontFamily'],
        fontPackage: map['iconFontPackage'],
      ),
      itemCount: map['itemCount'] ?? 0,
    );
  }
}