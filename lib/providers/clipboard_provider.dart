import 'package:flutter/material.dart';
import 'package:quickcopy/models/clipboard_item.dart';
import 'package:quickcopy/models/category.dart';
import 'package:quickcopy/services/database_service.dart';

class ClipboardProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<ClipboardItem> _clipboardItems = [];
  List<Category> _categories = [];
  
  String _selectedCategory = 'Tümü';
  String _searchQuery = '';
  bool _isLoading = false;
  
  // Son silinen öğeyi depolamak için değişken
  ClipboardItem? _lastDeletedItem;
  
  // Getters
  List<ClipboardItem> get clipboardItems => _clipboardItems;
  List<Category> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  ClipboardItem? get lastDeletedItem => _lastDeletedItem;
  
  // Filtrelenmiş Clipboarditem listesi
  List<ClipboardItem> get filteredItems {
    if (_searchQuery.isNotEmpty) {
      return _clipboardItems.where((item) {
        return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (item.description != null && 
                item.description!.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    } else if (_selectedCategory == 'Tümü') {
      return _clipboardItems;
    } else if (_selectedCategory == 'Favoriler') {
      return _clipboardItems.where((item) => item.isFavorite).toList();
    } else {
      return _clipboardItems.where((item) => item.categoryName == _selectedCategory).toList();
    }
  }
  
  // En sık kullanılan 5 öğeyi getir
  List<ClipboardItem> get mostUsedItems {
    final sortedItems = List<ClipboardItem>.from(_clipboardItems);
    sortedItems.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sortedItems.take(5).toList();
  }
  
  // Son eklenen 5 öğeyi getir
  List<ClipboardItem> get recentItems {
    final sortedItems = List<ClipboardItem>.from(_clipboardItems);
    sortedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedItems.take(5).toList();
  }
  
  // Yükleme durumunu güncelle
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  // Tüm verileri yükle
  Future<void> loadAll() async {
    _setLoading(true);
    await Future.wait([
      loadClipboardItems(),
      loadCategories(),
    ]);
    _setLoading(false);
  }
  
  // Clipboard öğelerini yükle
  Future<void> loadClipboardItems() async {
    _clipboardItems = await _databaseService.getAllClipboardItems();
    notifyListeners();
  }
  
  // Kategorileri yükle
  Future<void> loadCategories() async {
    _categories = await _databaseService.getAllCategories();
    notifyListeners();
  }
  
  // Yeni Clipboard öğesi ekle
  Future<void> addClipboardItem(ClipboardItem item) async {
    _setLoading(true);
    final id = await _databaseService.insertClipboardItem(item);
    final newItem = item.copyWith(id: id);
    _clipboardItems.add(newItem);
    _setLoading(false);
    notifyListeners();
    await loadCategories(); // Kategori sayılarını güncellemek için yeniden yükle
  }
  
  // Clipboard öğesini güncelle
  Future<void> updateClipboardItem(ClipboardItem item) async {
    _setLoading(true);
    await _databaseService.updateClipboardItem(item);
    final index = _clipboardItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _clipboardItems[index] = item;
    }
    _setLoading(false);
    notifyListeners();
    await loadCategories(); // Kategori sayılarını güncellemek için yeniden yükle
  }
  
  // Clipboard öğesini sil
  Future<void> deleteClipboardItem(int id) async {
    _setLoading(true);
    
    // Silinecek öğeyi bul ve sakla
    final itemIndex = _clipboardItems.indexWhere((item) => item.id == id);
    if (itemIndex != -1) {
      _lastDeletedItem = _clipboardItems[itemIndex];
    }
    
    await _databaseService.deleteClipboardItem(id);
    _clipboardItems.removeWhere((item) => item.id == id);
    _setLoading(false);
    notifyListeners();
    await loadCategories(); // Kategori sayılarını güncellemek için yeniden yükle
  }
  
  // Silinen öğeyi geri al
  Future<void> undoDelete() async {
    if (_lastDeletedItem != null) {
      _setLoading(true);
      // Silinen öğenin ID'sini null yap, böylece yeni bir öğe olarak eklenir
      final itemToRestore = _lastDeletedItem!.copyWith(id: null);
      final id = await _databaseService.insertClipboardItem(itemToRestore);
      final restoredItem = itemToRestore.copyWith(id: id);
      _clipboardItems.add(restoredItem);
      _lastDeletedItem = null; // Geri alındıktan sonra temizle
      _setLoading(false);
      notifyListeners();
      await loadCategories(); // Kategori sayılarını güncellemek için yeniden yükle
    }
  }
  
  // Favorilere ekle/çıkar
  Future<void> toggleFavorite(ClipboardItem item) async {
    final updatedItem = item.copyWith(
      isFavorite: !item.isFavorite,
      updatedAt: DateTime.now(),
    );
    await updateClipboardItem(updatedItem);
  }
  
  // Favorilere ekle/çıkar (optimize edilmiş)
  Future<ClipboardItem> toggleFavoriteOptimized(ClipboardItem item) async {
    // Ekranı yüklenme durumuna geçirmeden işlem yapıyoruz
    final updatedItem = item.copyWith(
      isFavorite: !item.isFavorite,
      updatedAt: DateTime.now(),
    );
    
    // Veritabanında güncelle
    await _databaseService.updateClipboardItem(updatedItem);
    
    // Listedeki elemanı güncelle
    final index = _clipboardItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _clipboardItems[index] = updatedItem;
      
      // Sadece favoriler ekranında isek ve bir öğe favorilerden çıkarıldıysa
      // filtrelenmiş liste değişeceği için tüm listeyi yenilemek gerekiyor
      if (_selectedCategory == 'Favoriler' && !updatedItem.isFavorite) {
        notifyListeners();
      }
      // Diğer durumlarda tüm ekranı yenilemiyoruz
    }
    
    return updatedItem; // Güncellenmiş öğeyi döndür
  }
  
  // Kullanım sayısını artır
  Future<void> incrementUsage(int id) async {
    await _databaseService.incrementUsageCount(id);
    final index = _clipboardItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _clipboardItems[index];
      _clipboardItems[index] = item.copyWith(
        usageCount: item.usageCount + 1,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
  
  // Yeni kategori ekle
  Future<void> addCategory(Category category) async {
    _setLoading(true);
    final id = await _databaseService.insertCategory(category);
    final newCategory = category.copyWith(id: id);
    _categories.add(newCategory);
    _setLoading(false);
    notifyListeners();
  }
  
  // Kategori güncelle
  Future<void> updateCategory(Category category) async {
    _setLoading(true);
    await _databaseService.updateCategory(category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
    _setLoading(false);
    notifyListeners();
  }
  
  // Kategori sil
  Future<void> deleteCategory(int id) async {
    _setLoading(true);
    await _databaseService.deleteCategory(id);
    _categories.removeWhere((category) => category.id == id);
    await loadClipboardItems(); // Kategori silindikten sonra öğeleri yeniden yükle
    _setLoading(false);
    notifyListeners();
  }
  
  // Seçili kategoriyi değiştir
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  // Arama sorgusunu değiştir
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}