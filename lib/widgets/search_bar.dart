import 'package:flutter/material.dart';

class AppSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function() onClear;
  final String hint;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    required this.onSearch,
    required this.onClear,
    this.hint = 'Ara...',
    this.autofocus = false,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onSearch,
              autofocus: widget.autofocus,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              style: theme.textTheme.bodyMedium,
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
          AnimatedOpacity(
            opacity: _controller.text.isEmpty ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: _controller.text.isEmpty
                ? const SizedBox.shrink()
                : InkWell(
                    onTap: _clearSearch,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.clear,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}