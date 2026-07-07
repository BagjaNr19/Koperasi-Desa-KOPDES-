import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'profile_page.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      Provider.of<CartProvider>(context, listen: false).getCart();
      productProvider.getCategories();
      productProvider.getProducts();
    });
  }

  void _onSearch() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.getProducts(search: _searchController.text);
  }

  void _onSortChanged(String? sortValue) {
    if (sortValue != null) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.getProducts(sort: sortValue);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KOPDES Mobile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistPage()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    if (cart.cartItems.isEmpty) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.cartItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bagian Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari produk...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onFieldSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _onSearch,
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // Bagian Sorting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Urutkan:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: productProvider.currentSort,
                  hint: const Text('Pilih'),
                  items: const [
                    DropdownMenuItem(value: 'price_asc', child: Text('Harga Termurah')),
                    DropdownMenuItem(value: 'price_desc', child: Text('Harga Termahal')),
                    DropdownMenuItem(value: 'newest', child: Text('Terbaru')),
                  ],
                  onChanged: _onSortChanged,
                ),
              ],
            ),
          ),

          // Bagian Kategori (Horizontal ListView)
          if (productProvider.categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: productProvider.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: const Text('Semua'),
                        backgroundColor: productProvider.currentCategoryId == null ? Colors.green.withValues(alpha: 0.2) : null,
                        onPressed: () {
                          productProvider.getProducts(categoryId: null);
                        },
                      ),
                    );
                  }
                  
                  final category = productProvider.categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text(category.name),
                      backgroundColor: productProvider.currentCategoryId == category.id ? Colors.green.withValues(alpha: 0.2) : null,
                      onPressed: () {
                        productProvider.getProducts(
                          categoryId: category.id,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),

          // Bagian Produk
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.errorMessage.isNotEmpty
                    ? Center(child: Text(productProvider.errorMessage))
                    : productProvider.products.isEmpty
                        ? const Center(child: Text('Produk belum tersedia'))
                        : Column(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.7,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: productProvider.products.length,
                                  itemBuilder: (context, index) {
                                    return ProductCard(
                                      product: productProvider.products[index],
                                    );
                                  },
                                ),
                              ),
                              if (productProvider.hasMore)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      productProvider.getProducts(isLoadMore: true);
                                    },
                                    child: const Text('Load More'),
                                  ),
                                ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}
