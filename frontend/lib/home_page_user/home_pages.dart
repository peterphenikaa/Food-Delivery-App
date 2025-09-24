import 'package:flutter/material.dart';
import 'product_list_page.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff8f8f8),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(radius: 18, backgroundColor: Colors.grey[300]),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GIAO ĐẾN",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Văn phòng Halal Lab",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Stack(
                    children: [
                      Icon(Icons.receipt_long, size: 28),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '2',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  text: "Chào Halal, ",
                  children: [
                    TextSpan(
                      text: "Chúc buổi chiều tốt lành!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Tìm món, nhà hàng",
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Danh mục", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                  Text("Xem tất cả", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.orange)),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    CategoryButton(
                      icon: Icons.fastfood,
                      label: "Hot Dog",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListPage(category: "Hot Dog"),
                          ),
                        );
                      },
                    ),

                    CategoryButton(
                      icon: Icons.fastfood,
                      label: "Hot Dog",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListPage(category: "Hot Dog"),
                          ),
                        );
                      },
                    ),
                    CategoryButton(
                      icon: Icons.fastfood,
                      label: "Hot Dog",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListPage(category: "Hot Dog"),
                          ),
                        );
                      },
                    ),

                  ],
                ),
              ),
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Nhà hàng đang mở", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                  Text("Xem tất cả", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.orange)),
                ],
              ),
              SizedBox(height: 16),
              // Restaurant Card
              RestaurantCard(
                imagePath: 'assets/restaurant_img1.jpg',
                name: "Nhà hàng Rose Garden",
                tags: "Burger - Gà - Cánh",
                rating: 4.7,
                free: true,
                duration: "20 phút",
              ),
              RestaurantCard(
                imagePath: 'assets/restaurant_img2.jpg',
                name: "Nhà hàng Green Bowl",
                tags: "Salad - Healthy",
                rating: 4.8,
                free: false,
                duration: "15 phút",
              ),
              SizedBox(height: 24),
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

  CategoryButton({required this.icon, required this.label, this.color = Colors.grey, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 13)),
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

  RestaurantCard({
    required this.imagePath,
    required this.name,
    required this.tags,
    required this.rating,
    required this.free,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.asset(imagePath, height: 110, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                SizedBox(height: 3),
                Text(tags, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                SizedBox(height: 9),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 17),
                    Text(rating.toString(), style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(width: 10),
                    if (free)
                      Row(
                        children: [
                          Icon(Icons.local_offer, color: Colors.orange, size: 15),
                          Text("Miễn phí", style: TextStyle(fontSize: 12)),
                          SizedBox(width: 12),
                        ],
                      ),
                    Icon(Icons.timer, color: Colors.orange, size: 15),
                    Text(duration, style: TextStyle(fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
