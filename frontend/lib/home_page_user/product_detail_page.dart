import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_item.dart';
import 'cart_provider.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  String selectedSize = 'M';
  final List<String> availableSizes = ['S', 'M', 'L'];
  final Map<String, String> sizeLabels = {
    'S': '10"',
    'M': '14"',
    'L': '16"',
  };

  int get currentPrice {
    return (widget.product['price'] ?? 0) as int;
  }

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final item = widget.product;
    
    final cartItem = CartItem(
      id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: item['name'] ?? '',
      image: item['image'],
      basePrice: (item['price'] ?? 0) as int,
      size: selectedSize,
      quantity: quantity,
      restaurant: 'Uttora Coffee House',
      category: item['category'] ?? '',
      description: item['description'],
    );

    cartProvider.addItem(cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm $quantity ${item['name']} (${sizeLabels[selectedSize]}) vào giỏ hàng'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Xem giỏ hàng',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.product;
    final String name = item['name'] ?? '';
    final String description = item['description'] ?? 'Món ăn ngon được chế biến tươi mỗi ngày.';
    final String category = item['category'] ?? '';
    final int basePrice = (item['price'] ?? 0) as int;
    final int deliveryTime = (item['deliveryTime'] ?? 20) as int;
    final double rating = (item['rating'] ?? 4.7).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: SafeArea(
        child: Column(
          children: [
            // Header with image
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Chi tiết sản phẩm', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 190,
                  color: const Color(0xffffe1c2),
                  alignment: Alignment.center,
                  child: item['image'] != null
                      ? Image.asset('assets/${item['image']}', fit: BoxFit.contain, height: 150)
                      : const Icon(Icons.local_pizza, size: 96, color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircleAvatar(radius: 10, backgroundColor: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Uttora Coffee House', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                    const SizedBox(height: 6),
                    Text(description,
                        style: TextStyle(color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(rating.toStringAsFixed(1)),
                        const SizedBox(width: 18),
                        const Icon(Icons.local_shipping_outlined, size: 18, color: Colors.green),
                        const SizedBox(width: 4),
                        const Text('Free'),
                        const SizedBox(width: 18),
                        const Icon(Icons.timer_outlined, size: 18, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Text('$deliveryTime min'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Text('SIZE', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(
                          '₫${currentPrice.toString()}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: availableSizes.map((size) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _SizeChip(
                            label: sizeLabels[size]!,
                            selected: selectedSize == size,
                            onTap: () => setState(() => selectedSize = size),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    const Text('INGREDIENTS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: const [
                      _IngredientIcon(icon: Icons.local_pizza),
                      SizedBox(width: 10),
                      _IngredientIcon(icon: Icons.egg_alt),
                      SizedBox(width: 10),
                      _IngredientIcon(icon: Icons.local_fire_department),
                      SizedBox(width: 10),
                      _IngredientIcon(icon: Icons.eco),
                    ]),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4)),
        ]),
        child: Row(
          children: [
            Text('₫${currentPrice.toString()}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
            const Spacer(),
            Container(
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(26)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _QtyButton(icon: Icons.remove, onTap: () => setState(() => quantity = quantity > 1 ? quantity - 1 : 1)),
                  const SizedBox(width: 6),
                  Text(quantity.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  _QtyButton(icon: Icons.add, onTap: () => setState(() => quantity = quantity + 1)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                final isInCart = cartProvider.isItemInCart(
                  item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  selectedSize,
                );
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInCart ? Colors.green : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  onPressed: _addToCart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isInCart) ...[
                        const Icon(Icons.check, size: 18, color: Colors.white),
                        const SizedBox(width: 4),
                      ],
                      Text(isInCart ? 'Đã thêm' : 'Thêm vào giỏ'),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SizeChip({Key? key, required this.label, required this.selected, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? Colors.orange : Colors.grey.shade300),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _IngredientIcon extends StatelessWidget {
  final IconData icon;
  const _IngredientIcon({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: 20, backgroundColor: const Color(0xfffff2ea), child: Icon(icon, color: Colors.orange));
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({Key? key, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}


