import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'product_detail_page.dart';
import 'cart_provider.dart';
import 'cart_item.dart';
import 'search_page.dart';
import 'dart:convert';

class ProductListPage extends StatefulWidget {
  final String category;

  ProductListPage({required this.category});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List products = [];
  List filteredProducts = [];
  bool loading = true;
  late String currentCategory;
  String sortBy = 'name'; // name, price, rating, deliveryTime
  bool sortAscending = true;
  double minPrice = 0;
  double maxPrice = 1000000;
  double minRating = 0;

  @override
  void initState() {
    super.initState();
    currentCategory = widget.category;
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final String baseUrl = kIsWeb
        ? 'http://localhost:3000'
        : (defaultTargetPlatform == TargetPlatform.android ? 'http://10.0.2.2:3000' : 'http://localhost:3000');

    final normalizedCategory = currentCategory.trim().toLowerCase();
    final bool isAll = normalizedCategory == 'tất cả danh mục';
    final Uri url = isAll
        ? Uri.parse('$baseUrl/api/foods')
        : Uri.parse('$baseUrl/api/foods?category=' + Uri.encodeQueryComponent(currentCategory.trim()));
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          filteredProducts = List.from(products);
          loading = false;
        });
        _applyFilters();
      } else {
        throw Exception('Lỗi tải dữ liệu (${response.statusCode})');
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }
  void _onCategorySelected(String value) {
    if (value != currentCategory) {
      setState(() {
        currentCategory = value;
        loading = true;
      });
      fetchProducts();
    }
  }

  void _applyFilters() {
    setState(() {
      filteredProducts = List.from(products);

      // Lọc theo giá
      filteredProducts = filteredProducts.where((product) {
        double price = (product['price'] ?? 0).toDouble();
        return price >= minPrice && price <= maxPrice;
      }).toList();

      // Lọc theo đánh giá
      filteredProducts = filteredProducts.where((product) {
        double rating = (product['rating'] ?? 0).toDouble();
        return rating >= minRating;
      }).toList();

      // Sắp xếp
      filteredProducts.sort((a, b) {
        dynamic aValue, bValue;

        switch (sortBy) {
          case 'name':
            aValue = a['name'] ?? '';
            bValue = b['name'] ?? '';
            break;
          case 'price':
            aValue = (a['price'] ?? 0).toDouble();
            bValue = (b['price'] ?? 0).toDouble();
            break;
          case 'rating':
            aValue = (a['rating'] ?? 0).toDouble();
            bValue = (b['rating'] ?? 0).toDouble();
            break;
          case 'deliveryTime':
            aValue = (a['deliveryTime'] ?? 0).toDouble();
            bValue = (b['deliveryTime'] ?? 0).toDouble();
            break;
          default:
            aValue = a['name'] ?? '';
            bValue = b['name'] ?? '';
        }

        if (aValue is String && bValue is String) {
          return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        } else if (aValue is num && bValue is num) {
          return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        }
        return 0;
      });
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Bộ lọc và sắp xếp'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sắp xếp theo:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: sortBy,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: 'name', child: Text('Tên')),
                        DropdownMenuItem(value: 'price', child: Text('Giá')),
                        DropdownMenuItem(value: 'rating', child: Text('Đánh giá')),
                        DropdownMenuItem(value: 'deliveryTime', child: Text('Thời gian giao hàng')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          sortBy = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: Text('Tăng dần'),
                            value: sortAscending,
                            onChanged: (value) {
                              setDialogState(() {
                                sortAscending = value!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('Khoảng giá (VND):', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Từ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setDialogState(() {
                                minPrice = double.tryParse(value) ?? 0;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Đến',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setDialogState(() {
                                maxPrice = double.tryParse(value) ?? 1000000;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('Đánh giá tối thiểu:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        double starValue = index + 1.0;
                        bool selected = minRating == starValue;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              minRating = starValue;
                            });
                          },
                          child: Icon(
                            Icons.star,
                            color: minRating >= starValue ? Colors.orange : Colors.grey[300],
                            size: 32,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      sortBy = 'name';
                      sortAscending = true;
                      minPrice = 0;
                      maxPrice = 1000000;
                      minRating = 0;
                    });
                  },
                  child: Text('Đặt lại'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _applyFilters();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Áp dụng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                PopupMenuButton<String>(
                  onSelected: _onCategorySelected,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: "Burger", child: Text("Burger")),
                    PopupMenuItem(value: "Pizza", child: Text("Pizza")),
                    PopupMenuItem(value: "Sandwich", child: Text("Sandwich")),
                    PopupMenuItem(value: "Hot Dog", child: Text("Hot Dog")),
                    PopupMenuItem(value: "Fast Food", child: Text("Fast Food")),
                    PopupMenuItem(value: "Salad", child: Text("Salad")),
                    PopupMenuItem(value: "Tất cả danh mục", child: Text("Tất cả")),
                  ],
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Text(currentCategory.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                CircleAvatar(
                  backgroundColor: Colors.black87,
                  radius: 18,
                  child: IconButton(
                    icon: Icon(Icons.search, color: Colors.white, size: 18),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchPage()),
                      );
                    },
                  ),
                ),
                SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 18,
                  child: IconButton(
                    icon: Icon(Icons.filter_alt, color: Colors.blueGrey, size: 18),
                    onPressed: _showFilterDialog,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : filteredProducts.isEmpty
          ? Center(child: Text('Không có sản phẩm phù hợp'))
          : ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final item = filteredProducts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: Map<String, dynamic>.from(item)),
                ),
              );
            },
            child: Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 85,
                  height: 85,
                  margin: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200],
                    image: item['image'] != null
                        ? DecorationImage(
                        image: AssetImage('assets/${item['image']}'),
                        fit: BoxFit.cover)
                        : null,
                  ),
                  child: item['image'] == null
                      ? Icon(Icons.restaurant, size: 30, color: Colors.grey)
                      : null,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17)),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Text(item['category'] ?? '',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            SizedBox(width: 8),
                            Icon(Icons.attach_money,
                                size: 15, color: Colors.orange[700]),
                            Text("${item['price'] ?? 0} VND",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        if (item['deliveryTime'] != null) ...[
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined,
                                  size: 15, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text("${item['deliveryTime']} min",
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ],
                          )
                        ],
                      ],
                    ),
                  ),
                ),
                // Add to cart button
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    final isInCart = cartProvider.isItemInCart(
                      item['_id'] ?? item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      'M', // Default size
                    );
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () {
                          if (!isInCart) {
                            final cartItem = CartItem(
                              id: item['_id'] ?? item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              name: item['name'] ?? '',
                              image: item['image'],
                              basePrice: (item['price'] ?? 0) as int,
                              size: 'M',
                              quantity: 1,
                              restaurant: 'Uttora Coffee House',
                              category: item['category'] ?? '',
                              description: item['description'],
                            );
                            cartProvider.addItem(cartItem);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã thêm ${item['name']} vào giỏ hàng'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isInCart ? Colors.green : Colors.orange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isInCart ? Colors.green : Colors.orange).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isInCart ? Icons.check : Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          );
        },
      ),
    );
  }
}
