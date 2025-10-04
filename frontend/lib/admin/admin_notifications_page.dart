import 'package:flutter/material.dart';
import 'admin_api.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({Key? key}) : super(key: key);

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  late final AdminApi _api;
  bool loading = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _api = AdminApi.fromDefaults();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await _api.fetchNotifications();
      setState(() => items = data);
    } catch (_) {
      setState(() => items = []);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Thông báo', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: Colors.orange))
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final n = items[index];
                final status = (n['status'] ?? '').toString();
                final orderId = (n['orderId'] ?? '').toString();
                final msg = (n['message'] ?? '').toString();
                final created = (n['createdAt'] ?? '').toString();
                return _NotificationTile(
                  title: 'Đơn $orderId',
                  subtitle: msg,
                  time: created,
                  status: status,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: items.length,
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String status;

  const _NotificationTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
  }) : super(key: key);

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'preparing':
        return Colors.orange;
      case 'delivering':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: _statusColor().withOpacity(0.15), child: Icon(Icons.notifications, color: _statusColor())),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700])),
            ]),
          ),
          const SizedBox(width: 8),
          Text(time.split('T').first, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}


