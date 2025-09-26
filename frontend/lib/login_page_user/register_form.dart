import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterFormPage extends StatefulWidget {
  @override
  _RegisterFormPageState createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _wardController = TextEditingController();
  final _cityController = TextEditingController();
  
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    print('🚀 Register button pressed');
    
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final houseNumber = _houseNumberController.text.trim();
    final ward = _wardController.text.trim();
    final city = _cityController.text.trim();

    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty || houseNumber.isEmpty || ward.isEmpty || city.isEmpty) {
      print('❌ Validation failed - empty fields');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      print('❌ Validation failed - passwords do not match');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (password.length < 6) {
      print('❌ Validation failed - password too short');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    print('✅ Validation passed, starting API call');
    setState(() => _loading = true);
    
    try {
      final uri = Uri.parse('http://localhost:3000/api/auth/register');
      final requestBody = jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'address': {
          'houseNumber': houseNumber,
          'ward': ward,
          'city': city,
        },
      });
      
      print('🌐 API URL: $uri');
      print('📤 Request body: $requestBody');
      
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('📥 Response status: ${res.statusCode}');
      print('📥 Response body: ${res.body}');

      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        print('✅ Registration successful');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );
        // Navigate back to login
        Navigator.pop(context);
      } else {
        final body = jsonDecode(res.body);
        print('❌ Registration failed: ${body['error']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['error'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      print('💥 Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      print('🔄 Setting loading = false');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top header with back button
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative lines
                    Positioned(
                      top: 40,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      right: 20,
                      child: Container(
                        width: 60,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    // Back button
                    Positioned(
                      top: 20,
                      left: 16,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    // Title
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            'Sign Up',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please sign up to get started',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Form
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    // Name field
                    Text('NAME', 
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      )
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'John doe',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Color(0xFFF3F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 16
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Email field
                    Text('EMAIL', 
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      )
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'example@gmail.com',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Color(0xFFF3F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 16
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // House Number field
                    Text('HOUSE NUMBER', 
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      )
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _houseNumberController,
                      decoration: InputDecoration(
                        hintText: '458',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Color(0xFFF3F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 16
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Ward field
                    Text('WARD', 
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      )
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _wardController,
                      decoration: InputDecoration(
                        hintText: 'Phuong 2',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Color(0xFFF3F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 16
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // City field
                    Text('CITY', 
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      )
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Ha Noi',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Color(0xFFF3F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 16
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Password field
                    Text('PASSWORD', 
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      )
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '• • • • • • • • • •',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Color(0xFFF3F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 16
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword 
                              ? Icons.visibility_off_outlined 
                              : Icons.visibility_outlined,
                            color: Colors.grey[500],
                          ),
                          onPressed: () => setState(() => 
                            _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Confirm Password field
                    Text('RE-TYPE PASSWORD', 
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      )
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: '• • • • • • • • • •',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Color(0xFFF3F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 16
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword 
                              ? Icons.visibility_off_outlined 
                              : Icons.visibility_outlined,
                            color: Colors.grey[500],
                          ),
                          onPressed: () => setState(() => 
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Sign Up button
                    ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}