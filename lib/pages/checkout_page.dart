import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../services/notification_service.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  void _handleCheckout() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Konfirmasi Checkout'),
          content: const Text('Apakah Anda yakin ingin memproses pesanan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Tutup dialog
                final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                
                bool isSuccess = await orderProvider.createOrder(
                  _addressController.text,
                  _notesController.text,
                );

                if (!mounted) return;

                if (isSuccess) {
                  // Show Notification
                  NotificationService().showNotification(
                    id: 1,
                    title: 'Pesanan Berhasil Dibuat!',
                    body: 'Pesanan Anda sedang diproses. Terima kasih telah berbelanja di KOPDES Mobile.',
                  );

                  // Refresh keranjang (seharusnya otomatis kosong dari server)
                  Provider.of<CartProvider>(context, listen: false).getCart();
                  
                  // Arahkan ke OrderSuccessPage
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderSuccessPage()),
                    (route) => route.isFirst,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(orderProvider.errorMessage)),
                  );
                }
              },
              child: const Text('Checkout', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartProvider.cartItems.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Ringkasan Pesanan
                    const Text('Ringkasan Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartProvider.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartProvider.cartItems[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.product.name),
                          subtitle: Text('${item.quantity} x ${currencyFormat.format(item.product.price)}'),
                          trailing: Text(currencyFormat.format(item.subtotal)),
                        );
                      },
                    ),
                    const Divider(thickness: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          currencyFormat.format(cartProvider.totalPrice),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Form Alamat
                    const Text('Informasi Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Lengkap',
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan alamat rumah Anda secara detail',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat wajib diisi';
                        }
                        if (value.length < 10) {
                          return 'Alamat minimal 10 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        border: OutlineInputBorder(),
                        hintText: 'Titip pesan untuk kurir',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),

                    // Tombol Buat Pesanan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: orderProvider.isLoading ? null : _handleCheckout,
                        child: orderProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Buat Pesanan', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
