import 'package:flutter/material.dart';
import '../ui/onboarding_card.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final PageController _controller = PageController();
  int _index = 0;

  void _next() {
    if (_index < 3) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Get started -> navigate to permission or home
      Navigator.pushReplacementNamed(context, '/permissions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  OnboardingCard(
                    title: 'All your favorites',
                    subtitle:
                        'Get all your loved foods in one place, you just place the order we do the rest',
                    buttonText: 'NEXT',
                    onButtonPressed: _next,
                    image: Container(color: Colors.blueGrey[200]),
                  ),
                  OnboardingCard(
                    title: 'All your favorites',
                    subtitle:
                        'Get all your loved foods in one place, you just place the order we do the rest',
                    buttonText: 'NEXT',
                    onButtonPressed: _next,
                    image: Container(color: Colors.blueGrey[200]),
                  ),
                  OnboardingCard(
                    title: 'Order from chosen chef',
                    subtitle:
                        'Get all your loved foods in one place, you just place the order we do the rest',
                    buttonText: 'NEXT',
                    onButtonPressed: _next,
                    image: Container(color: Colors.blueGrey[200]),
                  ),
                  OnboardingCard(
                    title: 'Free delivery offers',
                    subtitle:
                        'Get all your loved foods in one place, you just place the order we do the rest',
                    buttonText: 'GET STARTED',
                    onButtonPressed: _next,
                    image: Container(color: Colors.blueGrey[200]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => _buildDot(i == _index)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: EdgeInsets.symmetric(horizontal: 6),
      width: active ? 18 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.orange : Colors.orange.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
