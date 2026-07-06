import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistProvider extends ChangeNotifier {
  static const String _wishlistKey = 'wishlist_items';
  List<String> _wishlist = [];

  List<String> get wishlist => _wishlist;

  WishlistProvider() {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    _wishlist = prefs.getStringList(_wishlistKey) ?? [];
    notifyListeners();
  }

  Future<void> toggleWishlist(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    if (_wishlist.contains(productId)) {
      _wishlist.remove(productId);
    } else {
      _wishlist.add(productId);
    }
    await prefs.setStringList(_wishlistKey, _wishlist);
    notifyListeners();
  }

  bool isWishlisted(String productId) {
    return _wishlist.contains(productId);
  }
}
