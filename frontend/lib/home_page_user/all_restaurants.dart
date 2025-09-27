import 'package:flutter/material.dart';
import 'home_pages.dart';

class AllRestaurantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allRestaurants = [
      {
        "name": "Nhà hàng Rose Garden",
        "tags": "Burger - Gà - Cánh",
        "image": "assets/homepageUser/restaurant_img1.jpg",
        "rating": 4.7,
        "free": true,
        "duration": "20 phút",
      },
      {
        "name": "Nhà hàng Green Bowl",
        "tags": "Salad - Healthy",
        "image": "assets/homepageUser/restaurant_img2.jpg",
        "rating": 4.8,
        "free": false,
        "duration": "15 phút",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Tất cả nhà hàng"),
      ),
      body: ListView.builder(
        itemCount: allRestaurants.length,
        itemBuilder: (context, index) {
          final res = allRestaurants[index];
          return RestaurantCard(
            imagePath: res['image'],
            name: res['name'],
            tags: res['tags'],
            rating: res['rating'],
            free: res['free'],
            duration: res['duration'],
          );
        },
      ),
    );
  }
}
