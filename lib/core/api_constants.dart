class ApiConstants {
  // ── Base URL ──────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://api-tb-f2wk.onrender.com/api';

  // ── Auth Endpoints ─────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/profile';

  // ── Product Endpoints ──────────────────────────────────────────────────────────
  static const String products = '/products';
  static String productDetail(int id) => '/products/$id';
  static const String productCategories = '/products/categories';
  static String productsByCategory(String category) =>
      '/products/category/$category';

  // ── Cart Endpoints ─────────────────────────────────────────────────────────────
  static const String cart = '/cart';
  static String cartItem(int itemId) => '/cart/$itemId';

  // ── Order Endpoints ────────────────────────────────────────────────────────────
  static const String orders = '/orders';
  static String orderDetail(int id) => '/orders/$id';

  // ── Profile Endpoints ──────────────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';

  // ── Address Endpoints ──────────────────────────────────────────────────────────
  static const String addresses = '/addresses';
  static String addressDetail(int id) => '/addresses/$id';

  // ── Wishlist Endpoints ─────────────────────────────────────────────────────────
  static const String wishlist = '/wishlist';
  static String wishlistItem(int productId) => '/wishlist/$productId';

  // ── Search Endpoint ────────────────────────────────────────────────────────────
  static const String search = '/products/search';

  // ── HTTP Config ────────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Header Keys ───────────────────────────────────────────────────────────────
  static const String authHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String contentTypeJson = 'application/json';

  // ── Full URL Builders ──────────────────────────────────────────────────────────
  static String fullUrl(String endpoint) => '$baseUrl$endpoint';
}
