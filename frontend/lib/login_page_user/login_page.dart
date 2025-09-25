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
      // Get started -> navigate to login form (auth)
      Navigator.pushReplacementNamed(context, '/auth');
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
                    buttonColor: Colors.orange,
                    onButtonPressed: _next,
                    image: Container(color: Colors.blueGrey[200]),
                    pageIndex: 0,
                    activeIndex: _index,
                  ),
                  OnboardingCard(
                    title: 'All your favorites',
                    subtitle:
                        'Get all your loved foods in one place, you just place the order we do the rest',
                    buttonText: 'NEXT',
                    buttonColor: Colors.orange,
                    onButtonPressed: _next,
                    image: Container(color: Colors.blueGrey[200]),
                    pageIndex: 1,
                    activeIndex: _index,
                  ),
                  OnboardingCard(
                    title: 'Order from chosen chef',
                    subtitle:
                        'Get all your loved foods in one place, you just place the order we do the rest',
                    buttonText: 'NEXT',
                    buttonColor: Colors.orange,
                    onButtonPressed: _next,
                    image: Container(color: Colors.blueGrey[200]),
                    pageIndex: 2,
                    activeIndex: _index,
                  ),
                  OnboardingCard(
                    title: 'Free delivery offers',
                    subtitle:
                        'Get all your loved foods in one place, you just place the order we do the rest',
                    buttonText: 'GET STARTED',
                    buttonColor: Colors.orange,
                    onButtonPressed: _next,
                    image: Container(color: Colors.blueGrey[200]),
                    pageIndex: 3,
                    activeIndex: _index,
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.only(bottom: 18.0)),
          ],
        ),
      ),
    );
  }
}
