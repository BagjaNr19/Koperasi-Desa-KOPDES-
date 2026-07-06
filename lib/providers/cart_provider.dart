import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  double get totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> getCart() async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _cartItems = await _cartService.getCart();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addToCart(String productId, int quantity) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      await _cartService.addToCart(productId, quantity);
      await getCart(); // Refresh cart
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCart(String cartItemId, int quantity) async {
    if (quantity < 1) return false;
    _setLoading(true);
    _errorMessage = '';
    try {
      await _cartService.updateCart(cartItemId, quantity);
      await getCart(); // Refresh cart
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteCartItem(String cartItemId) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      await _cartService.deleteCartItem(cartItemId);
      await getCart(); // Refresh cart
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> clearCart() async {
    _setLoading(true);
    _errorMessage = '';
    try {
      await _cartService.clearCart();
      _cartItems.clear();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
