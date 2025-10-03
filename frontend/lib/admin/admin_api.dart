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
      running: (data['running'] ?? 0) as int,
      requests: (data['requests'] ?? 0) as int,
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
              total: (e['total'] as num).toDouble(),
              tooltip: (e['tooltip'] as String?) ?? '',
            ))
        .toList();
    return series;
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


