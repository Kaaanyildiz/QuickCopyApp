import 'package:flutter/material.dart';

class ClipboardItem {
  final int? id;
  final String title;
  final String content;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String categoryName;
  final Color? color;
  final bool isFavorite;
  final int usageCount;

  ClipboardItem({
    this.id,
    required this.title,
    required this.content,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.categoryName = 'Genel',
    this.color,
    this.isFavorite = false,
    this.usageCount = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ClipboardItem copyWith({
    int? id,
    String? title,
    String? content,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    Color? color,
    bool? isFavorite,
    int? usageCount,
  }) {
    return ClipboardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'categoryName': categoryName,
      'color': color?.value,
      'isFavorite': isFavorite ? 1 : 0,
      'usageCount': usageCount,
    };
  }

  factory ClipboardItem.fromMap(Map<String, dynamic> map) {
    return ClipboardItem(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      categoryName: map['categoryName'],
      color: map['color'] != null ? Color(map['color']) : null,
      isFavorite: map['isFavorite'] == 1,
      usageCount: map['usageCount'] ?? 0,
    );
  }
}