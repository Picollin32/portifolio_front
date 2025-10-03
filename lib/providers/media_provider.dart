import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item_model.dart';

class MediaProvider with ChangeNotifier {
  List<MediaItem> _items = [];
  int _nextId = 7;

  List<MediaItem> get items => _items;

  MediaProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadItems();
    
    // Initialize with default data if empty
    if (_items.isEmpty) {
      _items = [
        MediaItem(
          id: 1,
          title: 'The Last of Us Part II',
          type: MediaType.game,
          rating: 5,
          image: 'assets/images/the-last-of-us-part-ii-game-cover.png',
          badge: 'Platinado',
          genre: 'Action/Adventure',
          year: 2020,
        ),
        MediaItem(
          id: 2,
          title: 'Dune',
          type: MediaType.movie,
          rating: 4,
          image: 'assets/images/dune-movie-poster.png',
          genre: 'Sci-Fi',
          year: 2021,
        ),
        MediaItem(
          id: 3,
          title: 'Breaking Bad',
          type: MediaType.series,
          rating: 5,
          image: 'assets/images/breaking-bad-series-poster.png',
          badge: 'Finalizada',
          genre: 'Drama/Crime',
          year: 2008,
        ),
        MediaItem(
          id: 4,
          title: 'God of War',
          type: MediaType.game,
          rating: 5,
          image: 'assets/images/god-of-war-cover.png',
          badge: 'Zerado',
          genre: 'Action/Adventure',
          year: 2018,
        ),
        MediaItem(
          id: 5,
          title: 'Inception',
          type: MediaType.movie,
          rating: 5,
          image: 'assets/images/inception-inspired-poster.png',
          genre: 'Sci-Fi/Thriller',
          year: 2010,
        ),
        MediaItem(
          id: 6,
          title: 'Stranger Things',
          type: MediaType.series,
          rating: 4,
          image: 'assets/images/stranger-things-series-poster.png',
          badge: 'Finalizada',
          genre: 'Sci-Fi/Horror',
          year: 2016,
        ),
      ];
      await _saveItems();
    }
    notifyListeners();
  }

  Future<void> _loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString('mediaItems');
      
      if (itemsJson != null) {
        final List<dynamic> decoded = jsonDecode(itemsJson);
        _items = decoded.map((json) => MediaItem.fromJson(json)).toList();
        
        // Update nextId to be higher than the highest existing id
        if (_items.isNotEmpty) {
          _nextId = _items.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
        }
      }
    } catch (e) {
      debugPrint('Error loading media items: $e');
    }
  }

  Future<void> _saveItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('mediaItems', itemsJson);
    } catch (e) {
      debugPrint('Error saving media items: $e');
    }
  }

  List<MediaItem> getAll() {
    return [..._items];
  }

  MediaItem? getById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<MediaItem> getByType(MediaType type) {
    return _items.where((item) => item.type == type).toList();
  }

  Future<MediaItem> create(MediaItem item) async {
    final newItem = item.copyWith(id: _nextId++);
    _items.add(newItem);
    await _saveItems();
    notifyListeners();
    return newItem;
  }

  Future<MediaItem?> update(int id, MediaItem updates) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return null;

    _items[index] = updates.copyWith(id: id);
    await _saveItems();
    notifyListeners();
    return _items[index];
  }

  Future<bool> delete(int id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return false;

    _items.removeAt(index);
    await _saveItems();
    notifyListeners();
    return true;
  }

  List<MediaItem> search(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _items.where((item) {
      return item.title.toLowerCase().contains(lowercaseQuery) ||
             (item.genre?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  List<MediaItem> getRecent({int limit = 6}) {
    final sorted = [..._items]..sort((a, b) => (b.year ?? 0).compareTo(a.year ?? 0));
    return sorted.take(limit).toList();
  }

  List<MediaItem> getRecentByType(MediaType type, {int limit = 4}) {
    return getByType(type).take(limit).toList();
  }
}
