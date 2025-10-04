import 'package:flutter/material.dart';

class AdminPersonalInfoPage extends StatelessWidget {
  const AdminPersonalInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Thông tin cá nhân', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: const Center(
        child: Text('Personal Info - coming soon'),
      ),
    );
  }
}


