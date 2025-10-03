import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AdminApi {
  final String baseUrl;

  const AdminApi({required this.baseUrl});

  factory AdminApi.fromDefaults() {
    if (kIsWeb) {
      return AdminApi(baseUrl: 'http://localhost:3000');
    }
    if (Platform.isAndroid) {
      return AdminApi(baseUrl: 'http://10.0.2.2:3000');
    }
    return AdminApi(baseUrl: 'http://localhost:3000');
  }

  Future<AdminCounters> fetchCounters() async {
    final res = await http.get(Uri.parse('$baseUrl/api/orders/stats/counters'));
    if (res.statusCode != 200) {
      throw Exception('Lỗi tải counters: ${res.statusCode}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    return AdminCounters(
      running: (data['running'] ?? data['preparing'] ?? 0) as int,
      requests: (data['requests'] ?? data['requested'] ?? 0) as int,
    );
  }

  Future<List<RevenuePoint>> fetchRevenue({String granularity = 'daily'}) async {
    final url = Uri.parse('$baseUrl/api/orders/stats/revenue?granularity=$granularity');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Lỗi tải doanh thu: ${res.statusCode}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    final series = (data['series'] as List<dynamic>? ?? [])
        .map((e) => RevenuePoint(
              period: e['period'] as String,
              // Backend hiện tại trả về 'totalAmount'; fallback sang 'total' nếu có
              total: ((e['totalAmount'] ?? e['total']) as num).toDouble(),
              tooltip: (e['tooltip'] as String?) ?? '',
            ))
        .toList();
    return series;
  }

  Future<List<Map<String, dynamic>>> fetchRestaurants() async {
    final res = await http.get(Uri.parse('$baseUrl/api/restaurants'));
    if (res.statusCode != 200) {
      throw Exception('Lỗi tải nhà hàng: ${res.statusCode}');
    }
    final data = json.decode(res.body) as List<dynamic>;
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchTopFoods({int limit = 3}) async {
    final res = await http.get(Uri.parse('$baseUrl/api/orders/stats/top-foods?limit=$limit'));
    if (res.statusCode != 200) {
      throw Exception('Lỗi tải món phổ biến: ${res.statusCode}');
    }
    final data = json.decode(res.body) as List<dynamic>;
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchFoods({String? category, String? search}) async {
    final params = <String, String>{};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse('$baseUrl/api/foods').replace(queryParameters: params.isEmpty ? null : params);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Lỗi tải món ăn: ${res.statusCode}');
    }
    final data = json.decode(res.body) as List<dynamic>;
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createFood(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/api/foods');
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(body));
    if (res.statusCode != 201) {
      throw Exception('Lỗi tạo món: ${res.statusCode} ${res.body}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<void> deleteFood(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/foods/$id'));
    if (res.statusCode != 200) {
      throw Exception('Lỗi xóa món: ${res.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateFood(String id, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/foods/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('Lỗi cập nhật món: ${res.statusCode}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final res = await http.get(Uri.parse('$baseUrl/api/orders/notifications'));
    if (res.statusCode != 200) {
      throw Exception('Lỗi tải thông báo: ${res.statusCode}');
    }
    final data = json.decode(res.body) as List<dynamic>;
    return List<Map<String, dynamic>>.from(data);
  }
}

class AdminCounters {
  final int running;
  final int requests;
  const AdminCounters({required this.running, required this.requests});
}

class RevenuePoint {
  final String period;
  final double total;
  final String tooltip; // optional formatted date for daily buckets
  const RevenuePoint({required this.period, required this.total, this.tooltip = ''});
}


