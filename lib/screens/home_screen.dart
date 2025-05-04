import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quickcopy/constants/app_constants.dart';
import 'package:quickcopy/models/clipboard_item.dart';
import 'package:quickcopy/providers/clipboard_provider.dart';
import 'package:quickcopy/widgets/category_selector.dart';
import 'package:quickcopy/widgets/clipboard_item_card.dart';
import 'package:quickcopy/widgets/empty_state.dart';
import 'package:quickcopy/widgets/search_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Provider'daki verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClipboardProvider>(context, listen: false).loadAll();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _showAddItemDialog() {
    final provider = Provider.of<ClipboardProvider>(context, listen: false);
    final categories = provider.categories;
    
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final descriptionController = TextEditingController();
    
    String selectedCategory = categories.isNotEmpty ? categories.first.name : 'Genel';
    bool isFavorite = false; // Favori durumu için yeni değişken
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Yeni Metin Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        hintText: 'Örn: IBAN, E-posta, Adres',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'İçerik',
                        hintText: 'Kopyalanacak metin',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama (İsteğe bağlı)',
                        hintText: 'Metinle ilgili ek bilgiler',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.name,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Favori seçeneği ekleniyor
                    Row(
                      children: [
                        Checkbox(
                          value: isFavorite,
                          onChanged: (value) {
                            setState(() {
                              isFavorite = value ?? false;
                            });
                          },
                        ),
                        const Text('Favorilere Ekle'),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.star,
                          color: isFavorite ? Colors.amber : Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty || contentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Başlık ve içerik alanları zorunludur')),
                      );
                      return;
                    }
                    
                    final newItem = ClipboardItem(
                      title: titleController.text,
                      content: contentController.text,
                      description: descriptionController.text.isNotEmpty 
                        ? descriptionController.text 
                        : null,
                      categoryName: selectedCategory,
                      isFavorite: isFavorite, // Favori durumunu aktarıyoruz
                    );
                    
                    provider.addClipboardItem(newItem);
                    Navigator.pop(context);
                  },
                  child: const Text('Ekle'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showEditItemDialog(ClipboardItem item) {
    final provider = Provider.of<ClipboardProvider>(context, listen: false);
    final categories = provider.categories;
    
    final titleController = TextEditingController(text: item.title);
    final contentController = TextEditingController(text: item.content);
    final descriptionController = TextEditingController(text: item.description ?? '');
    
    String selectedCategory = item.categoryName;
    bool isFavorite = item.isFavorite;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Metni Düzenle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        hintText: 'Örn: IBAN, E-posta, Adres',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'İçerik',
                        hintText: 'Kopyalanacak metin',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama (İsteğe bağlı)',
                        hintText: 'Metinle ilgili ek bilgiler',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.name,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isFavorite,
                          onChanged: (value) {
                            setState(() {
                              isFavorite = value ?? false;
                            });
                          },
                        ),
                        const Text('Favorilere Ekle'),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.star,
                          color: isFavorite ? Colors.amber : Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty || contentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Başlık ve içerik alanları zorunludur')),
                      );
                      return;
                    }
                    
                    final updatedItem = item.copyWith(
                      title: titleController.text,
                      content: contentController.text,
                      description: descriptionController.text.isNotEmpty 
                        ? descriptionController.text 
                        : null,
                      categoryName: selectedCategory,
                      isFavorite: isFavorite,
                      updatedAt: DateTime.now(),
                    );
                    
                    provider.updateClipboardItem(updatedItem);
                    Navigator.pop(context);
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _copyToClipboard(ClipboardItem item) {
    final provider = Provider.of<ClipboardProvider>(context, listen: false);
    Clipboard.setData(ClipboardData(text: item.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppConstants.copiedMessage)),
    );
    if (item.id != null) {
      provider.incrementUsage(item.id!);
    }
  }

  Future<void> _deleteClipboardItem(ClipboardItem item) async {
    final provider = Provider.of<ClipboardProvider>(context, listen: false);
    
    // İlk önce öğeyi sil
    await provider.deleteClipboardItem(item.id!);
    
    // Snackbar ile geri alma seçeneği sunuyoruz
    ScaffoldMessenger.of(context).clearSnackBars(); // Önceki snackbar'ları temizle
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.title} silindi'),
        duration: const Duration(seconds: 5), // Uzun süre göster ki kullanıcı geri alabilsin
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            provider.undoDelete();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClipboardProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Ara...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    onChanged: provider.setSearchQuery,
                    autofocus: true,
                  )
                : const Text(AppConstants.appName),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      provider.setSearchQuery('');
                    }
                  });
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Tümü'),
                Tab(text: 'Sık Kullanılanlar'),
                Tab(text: 'Son Eklenenler'),
              ],
            ),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Kategori seçici
                    if (!_isSearching)
                      CategorySelector(
                        categories: provider.categories,
                        selectedCategory: provider.selectedCategory,
                        onCategorySelected: provider.setSelectedCategory,
                      ),
                    
                    // Ana içerik
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tümü veya filtrelenmiş öğeler
                          provider.filteredItems.isEmpty
                              ? const EmptyState(
                                  message: AppConstants.emptyListMessage,
                                  icon: Icons.note_alt_outlined,
                                )
                              : ListView.builder(
                                  itemCount: provider.filteredItems.length,
                                  padding: const EdgeInsets.all(8),
                                  itemBuilder: (context, index) {
                                    final item = provider.filteredItems[index];
                                    return ClipboardItemCard(
                                      item: item,
                                      onCopy: () => _copyToClipboard(item),
                                      onDelete: () => _deleteClipboardItem(item),
                                      onEdit: () => _showEditItemDialog(item),
                                      showUsageCount: false,
                                    ).animate().fadeIn().slideX();
                                  },
                                ),
                          
                          // Sık kullanılanlar
                          provider.mostUsedItems.isEmpty
                              ? const EmptyState(
                                  message: 'Henüz sık kullanılan öğe yok',
                                  icon: Icons.star_outline,
                                )
                              : ListView.builder(
                                  itemCount: provider.mostUsedItems.length,
                                  padding: const EdgeInsets.all(8),
                                  itemBuilder: (context, index) {
                                    final item = provider.mostUsedItems[index];
                                    return ClipboardItemCard(
                                      item: item,
                                      onCopy: () => _copyToClipboard(item),
                                      onDelete: () => _deleteClipboardItem(item),
                                      onEdit: () => _showEditItemDialog(item),
                                      showUsageCount: true,
                                    ).animate().fadeIn().slideX();
                                  },
                                ),
                          
                          // Son eklenenler
                          provider.recentItems.isEmpty
                              ? const EmptyState(
                                  message: 'Henüz öğe eklenmedi',
                                  icon: Icons.history_outlined,
                                )
                              : ListView.builder(
                                  itemCount: provider.recentItems.length,
                                  padding: const EdgeInsets.all(8),
                                  itemBuilder: (context, index) {
                                    final item = provider.recentItems[index];
                                    return ClipboardItemCard(
                                      item: item,
                                      onCopy: () => _copyToClipboard(item),
                                      onDelete: () => _deleteClipboardItem(item),
                                      onEdit: () => _showEditItemDialog(item),
                                      showUsageCount: false,
                                    ).animate().fadeIn().slideX();
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddItemDialog,
            tooltip: 'Yeni Metin Ekle',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}