import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  ProductModel? _selectedProduct;
  List<ReviewModel> _reviews = [];

  bool _isLoading = false;
  String _errorMessage = '';

  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentCategoryId;
  String? _currentSort;
  String? _currentSearch;

  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  String? get currentCategoryId => _currentCategoryId;
  String? get currentSort => _currentSort;

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  ProductModel? get selectedProduct => _selectedProduct;
  List<ReviewModel> get reviews => _reviews;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> getCategories() async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _categories = await _productService.getCategories();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getProducts({String? search, String? categoryId, String? sort, bool isLoadMore = false}) async {
    if (!isLoadMore) {
      _setLoading(true);
      _currentPage = 1;
      _hasMore = true;
      _products.clear();
      _currentSearch = search ?? _currentSearch;
      _currentCategoryId = categoryId ?? _currentCategoryId;
      _currentSort = sort ?? _currentSort;
    } else {
      if (!_hasMore || _isLoading) return;
      _setLoading(true);
      _currentPage++;
    }

    _errorMessage = '';
    try {
      final newProducts = await _productService.getProducts(
        search: _currentSearch,
        categoryId: _currentCategoryId,
        sort: _currentSort,
        page: _currentPage,
      );
      
      if (newProducts.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(newProducts);
        if (newProducts.length < 10) { // Asumsi per halaman 10
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

  Future<void> getProductDetail(String id) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _selectedProduct = await _productService.getProductDetail(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getProductReviews(String productId) async {
    _errorMessage = '';
    try {
      _reviews = await _productService.getProductReviews(productId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
