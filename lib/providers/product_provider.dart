import 'package:flutter/foundation.dart';

import '../core/api_constants.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

enum ProductLoadState { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────────
  ProductLoadState _state = ProductLoadState.initial;
  List<ProductModel> _products = [];
  List<String> _categories = [];
  String? _selectedCategory;
  String _searchQuery = '';
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // ── Getters ───────────────────────────────────────────────────────────────────
  ProductLoadState get state => _state;
  List<ProductModel> get products => _products;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ProductLoadState.loading;
  bool get hasMore => _hasMore;

  // ── Load Products ─────────────────────────────────────────────────────────────
  /// API response: {
  ///   "success": true,
  ///   "data": [...],
  ///   "pagination": { "page": 1, "limit": 10, "total": 25, "totalPages": 3 }
  /// }
  Future<void> loadProducts({bool refresh = false}) async {
    if (_state == ProductLoadState.loading && !refresh) return;
    if (_isLoadingMore) return;
    if (!_hasMore && !refresh) return;

    if (refresh) {
      _currentPage = 1;
      _products = [];
      _hasMore = true;
      _setState(ProductLoadState.loading);
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'limit': '10',
        if (_selectedCategory != null && _selectedCategory!.isNotEmpty)
          'category': _selectedCategory!,
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      };

      final response = await ApiService.instance.get(
        ApiConstants.products,
        queryParams: queryParams,
      );

      final List rawList = _extractList(response);
      final newProducts = rawList
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (refresh) {
        _products = newProducts;
      } else {
        _products = [..._products, ...newProducts];
      }

      // Check pagination from API
      final pagination = response is Map ? response['pagination'] : null;
      if (pagination is Map) {
        final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;
        _hasMore = _currentPage < totalPages;
      } else {
        _hasMore = newProducts.length >= 10;
      }

      _currentPage++;
      _errorMessage = null;
      _setState(ProductLoadState.loaded);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setState(ProductLoadState.error);
    } catch (e) {
      _errorMessage = 'Gagal memuat produk';
      _setState(ProductLoadState.error);
    } finally {
      _isLoadingMore = false;
    }
  }

  // ── Load Categories ───────────────────────────────────────────────────────────
  /// GET /api/categories → { "data": [{ "id": "...", "name": "...", "slug": "..." }] }
  Future<void> loadCategories() async {
    try {
      final response = await ApiService.instance.get('/categories');
      final List raw = _extractList(response);
      _categories = raw
          .map((e) {
            if (e is Map) return e['name']?.toString() ?? '';
            return e.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
      notifyListeners();
    } catch (_) {
      // Non-critical, silently ignore
    }
  }

  // ── Filter by Category ────────────────────────────────────────────────────────
  Future<void> filterByCategory(String? category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    await loadProducts(refresh: true);
  }

  // ── Search ────────────────────────────────────────────────────────────────────
  Future<void> search(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    await loadProducts(refresh: true);
  }

  void clearSearch() {
    _searchQuery = '';
    loadProducts(refresh: true);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  List _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      // API returns { "success": true, "data": [...] }
      final data = response['data'];
      if (data is List) return data;
      if (data is Map) {
        // nested data.products or data.items
        final inner = data['products'] ?? data['items'];
        if (inner is List) return inner;
      }
      // fallback keys
      return response['products'] as List? ??
          response['items'] as List? ??
          [];
    }
    return [];
  }

  void _setState(ProductLoadState state) {
    _state = state;
    notifyListeners();
  }
}
