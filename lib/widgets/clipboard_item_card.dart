import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:quickcopy/models/clipboard_item.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickcopy/providers/clipboard_provider.dart';

class ClipboardItemCard extends StatefulWidget {
  final ClipboardItem item;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool showUsageCount;

  const ClipboardItemCard({
    super.key,
    required this.item,
    required this.onCopy,
    required this.onDelete,
    this.onTap,
    this.onEdit,
    this.showUsageCount = false,
  });

  @override
  State<ClipboardItemCard> createState() => _ClipboardItemCardState();
}

class _ClipboardItemCardState extends State<ClipboardItemCard> {
  late ClipboardItem _item;
  
  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }
  
  @override
  void didUpdateWidget(ClipboardItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _item = widget.item;
    }
  }
  
  Future<void> _toggleFavorite() async {
    final provider = Provider.of<ClipboardProvider>(context, listen: false);
    final updatedItem = await provider.toggleFavoriteOptimized(_item);
    
    // Sadece bu kartı güncelle, tüm ekranı değil
    setState(() {
      _item = updatedItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy - HH:mm');
    
    return Slidable(
      key: ValueKey(_item.id),
      // Sadece silme butonu içeren sağa kaydırma aksiyonu
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: widget.onDelete),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Sil',
            flex: 1, // Tüm alanı kaplar
          ),
        ],
      ),
      // Sol kaydırma aksiyonları - düzenleme ve favori için
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onEdit?.call(),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Düzenle',
          ),
          SlidableAction(
            onPressed: (_) => _toggleFavorite(),
            backgroundColor: _item.isFavorite ? Colors.orange : Colors.blue,
            foregroundColor: Colors.white,
            icon: _item.isFavorite ? Icons.star : Icons.star_border,
            label: _item.isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: _item.color ?? Colors.transparent,
            width: _item.color != null ? 1 : 0,
          ),
        ),
        child: InkWell(
          onTap: widget.onTap ?? widget.onCopy,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Silme butonu
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: widget.onDelete,
                      tooltip: 'Sil',
                      iconSize: 18,
                      color: Colors.red,
                      splashRadius: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    // Düzenleme butonu
                    if (widget.onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: widget.onEdit,
                        tooltip: 'Düzenle',
                        iconSize: 18,
                        color: Colors.green,
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    const SizedBox(width: 8),
                    // Favori ikon butonu
                    IconButton(
                      icon: Icon(
                        _item.isFavorite ? Icons.star : Icons.star_outline,
                        color: _item.isFavorite ? Colors.amber : Colors.grey,
                      ),
                      onPressed: _toggleFavorite,
                      tooltip: _item.isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                      iconSize: 20,
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    // Sadece showUsageCount true ise Badge'i göster
                    if (widget.showUsageCount && _item.usageCount > 0)
                      Badge(
                        label: Text(_item.usageCount.toString()),
                        backgroundColor: 
                            _item.usageCount > 10 ? Colors.green : 
                            _item.usageCount > 5 ? Colors.blue : 
                            theme.colorScheme.secondary,
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: widget.onCopy,
                      tooltip: 'Kopyala',
                      iconSize: 20,
                      color: theme.colorScheme.primary,
                      splashRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _item.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                if (_item.description != null && _item.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _item.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        _item.categoryName,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      dateFormat.format(_item.updatedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}