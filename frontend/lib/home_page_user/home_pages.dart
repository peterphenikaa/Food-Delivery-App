import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_list_page.dart';
import 'search_page.dart';
import 'all_categories.dart';
import 'all_restaurants.dart';
import 'cart_provider.dart';
import 'cart_page.dart';
import 'restaurant_detail_page.dart';
import 'address_provider.dart';
import 'address_model.dart';
import 'edit_address_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> restaurants = [];
  bool isLoadingRestaurants = true;
  String? _latestLatLng;
  String? _latestAddress;
  Map<String, String>? _latestComponents; // street, ward, district, city

  @override
  void initState() {
    super.initState();
    // Load addresses when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = Provider.of<AddressProvider>(
        context,
        listen: false,
      );
      addressProvider.loadAddresses('user123'); // Replace with actual user ID
    });
    _loadRestaurants();
    _loadLatestLocation();
  }

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:3000'
        : 'http://localhost:3000';
  }

  Future<void> _loadRestaurants() async {
    setState(() => isLoadingRestaurants = true);
    try {
      final url = Uri.parse('$baseUrl/api/restaurants');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          restaurants = List<Map<String, dynamic>>.from(data);
          isLoadingRestaurants = false;
        });
      } else {
        setState(() {
          restaurants = [];
          isLoadingRestaurants = false;
        });
      }
    } catch (e) {
      print('Error loading restaurants: $e');
      setState(() {
        restaurants = [];
        isLoadingRestaurants = false;
      });
    }
  }

  Future<void> _loadLatestLocation() async {
    try {
      const userId = 'anonymous';
      final url = Uri.parse('$baseUrl/api/location/$userId/latest');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lat = data['lat'];
        final lng = data['lng'];
        setState(() {
          _latestLatLng = (lat != null && lng != null) ? '$lat, $lng' : null;
        });
        if (lat != null && lng != null) {
          final result = await _reverseGeocode(lat, lng);
          if (result != null) {
            setState(() {
              _latestAddress = result['display'] as String?;
              final c = result['components'];
              if (c is Map<String, String>) _latestComponents = c;
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> _reverseGeocode(num lat, num lng) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat='
          '$lat&lon=$lng&zoom=18&addressdetails=1');
      final resp = await http.get(
        uri,
        headers: {
          'User-Agent': 'food_delivery_app/1.0 (+https://example.com)',
          'Accept-Language': 'vi,en;q=0.8',
        },
      );
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        final address = body['address'];
        String? display; // Compose VN style manually
        Map<String, String> components = {};
        if (address is Map) {
          final road = address['road'] ?? address['residential'] ?? address['pedestrian'];
          final house = address['house_number'];
          final ward = address['ward'] ?? address['suburb'] ?? address['neighbourhood'] ?? address['quarter'] ?? address['hamlet'] ?? address['city_district'];
          final district = address['city_district'] ?? address['district'] ?? address['county'] ?? address['state_district'];
          final city = address['city'] ?? address['town'] ?? address['village'] ?? address['state'] ?? address['province'];

          String? street;
          if (road != null && house != null) street = '$house $road'; else street = road?.toString();
          if (street != null) components['street'] = street;
          if (ward != null) components['ward'] = ward.toString();
          if (district != null) components['district'] = district.toString();
          if (city != null) components['city'] = city.toString();
        }
        display = [
          components['street'],
          components['ward'],
          components['district'],
          components['city']
        ]
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .join(', ');

        return {'display': display.isNotEmpty ? display : null, 'components': components};
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              Consumer<AddressProvider>(
                builder: (context, addressProvider, child) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditAddressPage(
                                  userId: 'user123',
                                ),
                              ),
                            );
                            if (result == true) {
                              addressProvider.loadAddresses('user123');
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "GIAO ĐẾN",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _latestAddress ??
                                    (_latestComponents != null
                                        ? [
                                            _latestComponents?['ward'],
                                            _latestComponents?['district'],
                                            _latestComponents?['city']
                                          ]
                                            .whereType<String>()
                                            .where((s) => s.trim().isNotEmpty)
                                            .join(', ')
                                        : (addressProvider.defaultAddress?.shortAddress ??
                                            "Văn phòng Halal Lab")),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (addressProvider.defaultAddress != null)
                                const Text(
                                  "Nhấn để thay đổi",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CartPage(),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                const Icon(Icons.shopping_cart, size: 28),
                                if (cartProvider.itemCount > 0)
                                  Positioned(
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      child: Text(
                                        cartProvider.itemCount.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  text: "Chào Halal, ",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Chúc ngày mới tốt lành!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SearchPage()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          "Tìm món, nhà hàng",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Danh mục",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AllCategoriesPage()),
                      );
                    },
                    child: const Text(
                      "Xem tất cả",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    CategoryButton(
                      icon: Icons.fastfood,
                      label: "Tất cả danh mục",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductListPage(category: "Tất cả danh mục"),
                          ),
                        );
                      },
                    ),
                    CategoryButton(
                      icon: Icons.lunch_dining,
                      label: "Burger",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductListPage(category: "Burger"),
                          ),
                        );
                      },
                    ),
                    CategoryButton(
                      icon: Icons.local_pizza,
                      label: "Pizza",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductListPage(category: "Pizza"),
                          ),
                        );
                      },
                    ),
                    CategoryButton(
                      icon: Icons.lunch_dining,
                      label: "Sandwich",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductListPage(category: "Sandwich"),
                          ),
                        );
                      },
                    ),
                    CategoryButton(
                      icon: Icons.set_meal,
                      label: "Hot Dog",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductListPage(category: "Hot Dog"),
                          ),
                        );
                      },
                    ),
                    CategoryButton(
                      icon: Icons.fastfood,
                      label: "Fast Food",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductListPage(category: "Fast Food"),
                          ),
                        );
                      },
                    ),
                    CategoryButton(
                      icon: Icons.emoji_food_beverage,
                      label: "Salad",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductListPage(category: "Salad"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Nhà hàng đang mở header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nhà hàng đang mở",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AllRestaurantsPage()),
                      );
                    },
                    child: const Text(
                      "Xem tất cả",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (isLoadingRestaurants)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (restaurants.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Không có nhà hàng nào',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                ...restaurants.take(2).map((restaurant) {
                  return RestaurantCard(
                    imagePath: restaurant['image'] != null
                        ? 'assets/${restaurant['image']}'
                        : 'assets/homepageUser/restaurant_img1.jpg',
                    name: restaurant['name'] ?? 'Restaurant',
                    tags: (restaurant['categories'] as List?)?.join(' - ') ?? 'Food',
                    rating: (restaurant['rating'] ?? 4.7).toDouble(),
                    free: true,
                    duration: '${restaurant['deliveryTime'] ?? 20} phút',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailPage(
                            restaurant: restaurant,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const CategoryButton({
    Key? key,
    required this.icon,
    required this.label,
    this.color = Colors.grey,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String imagePath, name, tags, duration;
  final double rating;
  final bool free;
  final VoidCallback? onTap;

  const RestaurantCard({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.tags,
    required this.rating,
    required this.free,
    required this.duration,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Image.asset(
                imagePath,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 110,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, size: 50),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tags,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 17),
                      Text(
                        rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      if (free)
                        Row(
                          children: const [
                            Icon(
                              Icons.local_offer,
                              color: Colors.orange,
                              size: 15,
                            ),
                            Text("Miễn phí", style: TextStyle(fontSize: 12)),
                            SizedBox(width: 12),
                          ],
                        ),
                      Icon(Icons.timer, color: Colors.orange, size: 15),
                      Text(duration, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}