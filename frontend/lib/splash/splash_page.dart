import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // show splash for ~5 seconds then go to login/onboarding
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // make image take available space (width & height)
              Expanded(
                child: Image.asset(
                  'assets/login/login_img1.jpg',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // log to console and show a fallback icon
                    // Check terminal where `flutter run` is running for this message
                    print(
                        'ERROR loading asset assets/login/login_img1.jpg: $error');
                    return Center(
                      child:
                          Icon(Icons.fastfood, size: 120, color: Colors.orange),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
