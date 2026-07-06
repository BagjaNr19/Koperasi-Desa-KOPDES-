import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    // Memfilter produk yang ada di wishlist
    final wishlistedProducts = productProvider.products
        .where((product) => wishlistProvider.isWishlisted(product.id ?? ''))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist Tersimpan'),
      ),
      body: wishlistedProducts.isEmpty
          ? const Center(child: Text('Belum ada produk yang disukai'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: wishlistedProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: wishlistedProducts[index]);
              },
            ),
    );
  }
}
