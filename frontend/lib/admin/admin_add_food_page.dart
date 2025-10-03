import 'package:flutter/material.dart';
import 'admin_api.dart';

class AdminAddFoodPage extends StatefulWidget {
  final Map<String, dynamic>? initial; // if provided -> edit mode
  const AdminAddFoodPage({Key? key, this.initial}) : super(key: key);

  @override
  State<AdminAddFoodPage> createState() => _AdminAddFoodPageState();
}

class _AdminAddFoodPageState extends State<AdminAddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _image = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _category = TextEditingController();
  final TextEditingController _ingredientsInput = TextEditingController();

  bool pickUp = true;
  bool delivery = false;
  bool saving = false;
  late final AdminApi _api;

  @override
  void initState() {
    super.initState();
    _api = AdminApi.fromDefaults();
    // preload if editing
    final init = widget.initial;
    if (init != null) {
      _name.text = (init['name'] ?? '').toString();
      _price.text = ((init['price'] ?? 0) as num).toString();
      _image.text = (init['image'] ?? '').toString();
      _description.text = (init['description'] ?? '').toString();
      _category.text = (init['category'] ?? '').toString();
      final ingredients = (init['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? [];
      _ingredientsInput.text = ingredients.join(', ');
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _image.dispose();
    _description.dispose();
    _category.dispose();
    _ingredientsInput.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      final ingredients = _ingredientsInput.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final body = {
        'name': _name.text.trim(),
        'category': _category.text.trim(),
        'price': int.tryParse(_price.text.trim()) ?? 0,
        'image': _image.text.trim(),
        'description': _description.text.trim(),
        'ingredients': ingredients,
      };
      if (widget.initial != null && widget.initial!['_id'] != null) {
        await _api.updateFood(widget.initial!['_id'].toString(), body);
      } else {
        await _api.createFood(body);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm món ăn thành công')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo món thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Thêm món mới', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TÊN MÓN'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _name,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên món' : null,
                decoration: _decoration('Ví dụ: Chicken Bhuna'),
              ),
              const SizedBox(height: 16),
              const Text('GIÁ (VND)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                validator: (v) => (int.tryParse(v ?? '') == null) ? 'Nhập số hợp lệ' : null,
                decoration: _decoration('60000'),
              ),
              const SizedBox(height: 16),
              const Text('DANH MỤC'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _category,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập danh mục' : null,
                decoration: _decoration('Burger / Pizza / ...'),
              ),
              const SizedBox(height: 16),
              const Text('HÌNH (đường dẫn assets)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _image,
                decoration: _decoration('assets/homepageUser/burger_img1.jpg'),
              ),
              const SizedBox(height: 16),
              const Text('MÔ TẢ'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _description,
                minLines: 2,
                maxLines: 3,
                decoration: _decoration('Mô tả ngắn...'),
              ),
              const SizedBox(height: 16),
              const Text('NGUYÊN LIỆU (ngăn cách bằng dấu phẩy)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _ingredientsInput,
                minLines: 1,
                maxLines: 2,
                decoration: _decoration('Salt, Chicken, Onion'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(saving ? 'Đang lưu...' : 'LƯU'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orange, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    );
  }
}


