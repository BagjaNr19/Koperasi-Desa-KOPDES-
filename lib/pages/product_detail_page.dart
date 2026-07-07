import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';
import '../services/review_service.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _reviewFormKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.getProductDetail(widget.productId);
      productProvider.getProductReviews(widget.productId);
    });
  }

  void _submitReview() async {
    if (_reviewFormKey.currentState!.validate()) {
      setState(() => _isSubmittingReview = true);
      try {
        final reviewService = ReviewService();
        await reviewService.createReview(widget.productId, _rating, _commentController.text);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ulasan berhasil dikirim')));
        _commentController.clear();
        _rating = 5.0;
        
        // Refresh ulasan
        Provider.of<ProductProvider>(context, listen: false).getProductReviews(widget.productId);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) setState(() => _isSubmittingReview = false);
      }
    }
  }

  void _addToCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    bool success = await cartProvider.addToCart(widget.productId, 1);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil ditambahkan ke keranjang')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cartProvider.errorMessage)));
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final product = productProvider.selectedProduct;
    final reviews = productProvider.reviews;

    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          IconButton(
            icon: Icon(
              wishlistProvider.isWishlisted(widget.productId) ? Icons.favorite : Icons.favorite_border,
              color: wishlistProvider.isWishlisted(widget.productId) ? Colors.red : null,
            ),
            onPressed: () {
              wishlistProvider.toggleWishlist(widget.productId);
            },
          ),
        ],
      ),
      body: productProvider.isLoading || product == null
          ? const Center(child: CircularProgressIndicator())
          : productProvider.errorMessage.isNotEmpty
              ? Center(child: Text(productProvider.errorMessage))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Gambar produk
                    if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                      Image.network(
                        product.imageUrl!,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 100),
                      )
                    else
                      const Icon(Icons.image, size: 100, color: Colors.grey),
                    const SizedBox(height: 16),

                    // Nama dan Harga
                    Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(product.price),
                      style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Info Singkat (Stok, Kategori, Rating)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Stok: ${product.stock}', style: const TextStyle(fontSize: 16)),
                        if (product.category != null)
                          Text('Kategori: ${product.category}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (product.rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text('${product.rating!.toStringAsFixed(1)} / 5.0'),
                          const SizedBox(width: 16),
                          Text('(${reviews.length} ulasan)'),
                        ],
                      ),
                    const Divider(height: 32),

                    // Deskripsi
                    const Text('Deskripsi Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(product.description ?? 'Tidak ada deskripsi', style: const TextStyle(fontSize: 16)),
                    const Divider(height: 32),

                    // Ulasan
                    const Text('Ulasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (reviews.isEmpty)
                      const Text('Belum ada ulasan untuk produk ini')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(review.userName ?? 'Anonim'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 14, color: Colors.orange),
                                      Text(' ${review.rating}'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(review.comment),
                                ],
                              ),
                              trailing: (review.userId != null && 
                                         Provider.of<AuthProvider>(context, listen: false).user?.id == review.userId)
                                  ? IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () async {
                                        final provider = Provider.of<ProductProvider>(context, listen: false);
                                        final messenger = ScaffoldMessenger.of(context);
                                        try {
                                          await ReviewService().deleteReview(review.id ?? '');
                                          
                                          if (!mounted) return;
                                          provider.getProductReviews(widget.productId);
                                          messenger.showSnackBar(const SnackBar(content: Text('Ulasan dihapus')));
                                        } catch (e) {
                                          if (!mounted) return;
                                          messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                                        }
                                      },
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    const Divider(height: 32),

                    // Tulis Ulasan
                    const Text('Tulis Ulasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Form(
                      key: _reviewFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Rating: '),
                              DropdownButton<double>(
                                value: _rating,
                                items: [1.0, 2.0, 3.0, 4.0, 5.0].map((r) {
                                  return DropdownMenuItem(value: r, child: Text(r.toString()));
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    if (val != null) _rating = val;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              labelText: 'Komentar',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Komentar wajib diisi';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isSubmittingReview ? null : _submitReview,
                            child: _isSubmittingReview
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Kirim Ulasan'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: productProvider.isLoading || product == null
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return ElevatedButton(
                    onPressed: cartProvider.isLoading ? null : _addToCart,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: cartProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Tambah ke Keranjang', style: TextStyle(fontSize: 18)),
                  );
                },
              ),
            ),
    );
  }
}
