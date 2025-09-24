import 'package:flutter/material.dart';

class ProductListPage extends StatelessWidget {
  final String category;

  ProductListPage({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách - $category'),
      ),
      body: Center(
        child: Text('Danh sách sản phẩm cho danh mục: $category'),
      ),
    );
  }
}
