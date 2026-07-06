import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/order_detail_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  OrderDetailModel? _selectedOrder;
  bool _isLoading = false;
  String _errorMessage = '';

  int _currentPage = 1;
  bool _hasMore = true;

  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  List<OrderModel> get orders => _orders;
  OrderDetailModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> getOrders({bool isLoadMore = false}) async {
    if (!isLoadMore) {
      _setLoading(true);
      _currentPage = 1;
      _hasMore = true;
      _orders.clear();
    } else {
      if (!_hasMore || _isLoading) return;
      _setLoading(true);
      _currentPage++;
    }
    
    _errorMessage = '';
    try {
      final newOrders = await _orderService.getOrders(page: _currentPage);
      if (newOrders.isEmpty) {
        _hasMore = false;
      } else {
        _orders.addAll(newOrders);
        if (newOrders.length < 10) { // Asumsi max 10 item per page
          _hasMore = false;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (isLoadMore) _currentPage--; // rollback
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getOrderDetail(String id) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _selectedOrder = await _orderService.getOrderDetail(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createOrder(String shippingAddress, String? notes) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      await _orderService.createOrder(shippingAddress, notes);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
