import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home_pages.dart';

class PermissionPage extends StatelessWidget {
  Future<void> _requestPermissions(BuildContext context) async {
    var location = await Permission.location.request();
    // var notif = await Permission.notification.request();

    if (location.isGranted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn cần cấp quyền để tiếp tục")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                ),
                child: Image.asset(
                  'assets/Map_permission.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _requestPermissions(context),
                  icon: Icon(Icons.location_on, color: Colors.white),
                  label: Text(
                    "CẤP QUYỀN VỊ TRÍ",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF4E02),
                    minimumSize: Size(230, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14),
              Text(
                "NHÀ HÀNG SẼ TRUY CẬP VỊ TRÍ CỦA BẠN\nCHỈ KHI BẠN SỬ DỤNG ỨNG DỤNG",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
