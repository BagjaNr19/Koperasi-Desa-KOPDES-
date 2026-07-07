import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).getOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.selectedOrder;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: orderProvider.isLoading || order == null
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.errorMessage.isNotEmpty
              ? Center(child: Text(orderProvider.errorMessage))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Status & Info Dasar
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${order.status.toUpperCase()}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Tanggal: ${order.createdAt}'),
                            const SizedBox(height: 8),
                            const Text('Alamat Pengiriman:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(order.shippingAddress),
                            if (order.notes != null && order.notes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Catatan:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(order.notes!),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Daftar Item
                    const Text('Daftar Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return Card(
                          child: ListTile(
                            leading: item.product.imageUrl != null
                                ? Image.network(item.product.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                                : const Icon(Icons.image, size: 50),
                            title: Text(item.product.name),
                            subtitle: Text('${item.quantity} x ${currencyFormat.format(item.price)}'),
                            trailing: Text(currencyFormat.format(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                    const Divider(thickness: 2, height: 32),
                    
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          currencyFormat.format(order.totalAmount),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
