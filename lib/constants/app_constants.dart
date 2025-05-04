import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppConstants {
  // Uygulama bilgileri
  static const String appName = 'QuickCopy';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sık kullanılan metinleri hızlıca kopyalayın';
  
  // Animasyon süreleri
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Hızlı erişim kategorileri için simgeler
  static const Map<String, IconData> categoryIcons = {
    'Genel': Icons.category,
    'Kişisel': Icons.person,
    'İş': Icons.work,
    'Banka': Icons.account_balance,
    'E-posta': Icons.email,
    'Adres': Icons.location_on,
    'Telefon': Icons.phone,
    'Şifre': Icons.password,
    'Web Sitesi': Icons.web,
    'Sosyal Medya': FontAwesomeIcons.hashtag,
    'Fatura': Icons.receipt,
    'Sağlık': Icons.favorite,
    'Eğitim': Icons.school,
    'Seyahat': Icons.flight,
    'Alışveriş': Icons.shopping_cart,
    'Diğer': Icons.more_horiz,
  };
  
  // Kategori renkleri
  static const List<Color> categoryColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.lightBlue,
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.cyan,
    Colors.red,
    Colors.brown,
    Colors.lime,
    Colors.blueGrey,
  ];
  
  // Uygulama içi mesajlar
  static const String emptyListMessage = 'Henüz kayıtlı metin yok.\nEklemek için + butonuna dokunun.';
  static const String searchEmptyMessage = 'Arama sonucu bulunamadı';
  static const String copiedMessage = 'Panoya kopyalandı';
  static const String deleteConfirmMessage = 'Bu öğeyi silmek istediğinizden emin misiniz?';
  static const String deleteCategoryConfirmMessage = 'Bu kategoriyi silmek istediğinizden emin misiniz? İçindeki tüm metinler Genel kategorisine taşınacak.';
  static const String categoryExistsMessage = 'Bu isimde bir kategori zaten var';
  static const String requiredFieldMessage = 'Bu alan zorunludur';
  
  // Rota isimleri
  static const String homeRoute = '/';
  static const String detailRoute = '/detail';
  static const String addItemRoute = '/add-item';
  static const String editItemRoute = '/edit-item';
  static const String categoryListRoute = '/categories';
  static const String settingsRoute = '/settings';
  static const String searchRoute = '/search';
  static const String favoritesRoute = '/favorites';
}