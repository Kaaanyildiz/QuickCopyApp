import 'package:flutter/material.dart';
import 'package:quickcopy/models/category.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "Tümü" seçeneği
          _buildCategoryChip(
            context: context,
            name: 'Tümü',
            icon: Icons.all_inclusive,
            color: theme.colorScheme.primary,
            itemCount: categories.fold<int>(0, (sum, category) => sum + (category.itemCount)),
            isSelected: selectedCategory == 'Tümü',
            onTap: () => onCategorySelected('Tümü'),
          ),
          // "Favoriler" seçeneği
          _buildCategoryChip(
            context: context,
            name: 'Favoriler',
            icon: Icons.star,
            color: Colors.amber,
            itemCount: null, // Favori sayısı dinamik olarak hesaplanacak
            isSelected: selectedCategory == 'Favoriler',
            onTap: () => onCategorySelected('Favoriler'),
          ),
          ...categories.map((category) {
            return _buildCategoryChip(
              context: context,
              name: category.name,
              icon: category.icon,
              color: category.color,
              itemCount: category.itemCount,
              isSelected: selectedCategory == category.name,
              onTap: () => onCategorySelected(category.name),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required BuildContext context,
    required String name,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    int? itemCount,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Chip(
          avatar: CircleAvatar(
            backgroundColor: isSelected 
                ? theme.colorScheme.onPrimary 
                : color.withOpacity(0.8),
            child: Icon(
              icon, 
              size: 18,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onPrimary,
            ),
          ),
          label: Text(
            itemCount != null && itemCount > 0
                ? '$name ($itemCount)'
                : name,
          ),
          backgroundColor: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceVariant,
          labelStyle: TextStyle(
            color: isSelected 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          visualDensity: VisualDensity.compact,
          elevation: isSelected ? 2 : 0,
          shadowColor: color.withOpacity(0.5),
        ),
      ).animate(target: isSelected ? 1 : 0)
        .scaleXY(end: 1.05, duration: const Duration(milliseconds: 200))
        .elevation(end: 5),
    );
  }
}