import 'package:flutter/material.dart';
import 'admin_api.dart';

String formatCurrencyVND(double v) {
  final s = v.toStringAsFixed(0);
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
      buf.write(',');
    }
  }
  return '₫${buf.toString()}';
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _selectedLocation = 'Văn phòng Halal Lab';
  String _filter = 'Hàng ngày';
  late final AdminApi _api;

  int runningOrders = 0;
  int orderRequests = 0;

  final Map<String, List<double>> _mockRevenueByFilter = {
    'Hàng ngày': [],
    'Hàng tuần': [],
    'Hàng tháng': [],
  };
  final Map<String, List<RevenuePoint>> _pointsByFilter = {
    'Hàng ngày': [],
    'Hàng tuần': [],
    'Hàng tháng': [],
  };

  @override
  Widget build(BuildContext context) {
    final points = _pointsByFilter[_filter] ?? const [];
    final seriesForChart = points.isNotEmpty
        ? points.map((e) => e.total).toList()
        : (_mockRevenueByFilter[_filter] ?? const []);
    final labelsDyn = points.isNotEmpty ? points.map((e) => e.period).toList() : labelsForFilter(_filter);
    final tooltipsDyn = points.isNotEmpty
        ? points.map((e) => e.tooltip).toList()
        : List<String>.filled(labelsDyn.length, '');
    final double totalRevenue = seriesForChart.isNotEmpty
        ? seriesForChart.fold(0.0, (prev, v) => prev + v)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                selectedLocation: _selectedLocation,
                onChangeLocation: (value) => setState(() {
                  _selectedLocation = value;
                }),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: runningOrders.toString().padLeft(2, '0'),
                      label: 'Đơn đang xử lý',
                      icon: Icons.local_shipping_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: orderRequests.toString().padLeft(2, '0'),
                      label: 'Yêu cầu đơn hàng',
                      icon: Icons.pending_actions_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _RevenueCard(
                total: totalRevenue,
                filter: _filter,
                onFilterChanged: (value) {
                  setState(() => _filter = value);
                  _loadRevenue();
                },
                series: seriesForChart,
                labels: labelsDyn,
                tooltips: tooltipsDyn,
              ),
              const SizedBox(height: 16),
              _ReviewsPreview(rating: 4.9, totalReviews: 20),
              const SizedBox(height: 16),
              const _PopularItemsSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomBar(onCenterTap: () {}),
    );
  }

  @override
  void initState() {
    super.initState();
    _api = AdminApi.fromDefaults();
    _loadCounters();
    _loadRevenue();
  }

  Future<void> _loadCounters() async {
    try {
      final c = await _api.fetchCounters();
      setState(() {
        runningOrders = c.running;
        orderRequests = c.requests;
      });
    } catch (_) {
      // fallback giữ mock
    }
  }

  Future<void> _loadRevenue() async {
    try {
      final g = _filter == 'Hàng ngày'
          ? 'daily'
          : _filter == 'Hàng tuần'
              ? 'weekly'
              : 'monthly';
      final series = await _api.fetchRevenue(granularity: g);
      setState(() {
        // Doanh thu chỉ tính đơn đã thanh toán (paid) theo API backend
        _pointsByFilter[_filter] = series;
        _mockRevenueByFilter[_filter] = series.map((e) => e.total).toList();
      });
    } catch (_) {
      // fallback giữ mock
    }
  }

  List<double> _padSeries(List<double> input, int target) {
    if (input.isEmpty) return List<double>.filled(target, 0);
    if (input.length >= target) return input;
    final padding = List<double>.filled(target - input.length, 0);
    return [...padding, ...input];
  }

  List<String> _padStringList(List<String> input, int target) {
    if (input.isEmpty) return List<String>.filled(target, '');
    if (input.length >= target) return input;
    final padding = List<String>.filled(target - input.length, '');
    return [...padding, ...input];
  }

  List<String> labelsForFilter(String filter) {
    if (filter == 'Hàng ngày') {
      return ['T2','T3','T4','T5','T6'];
    }
    if (filter == 'Hàng tuần') {
      return ['Tuần 1','Tuần 2','Tuần 3','Tuần 4'];
    }
    return List<String>.generate(5, (i) => '');
  }
}

class _Header extends StatelessWidget {
  final String selectedLocation;
  final ValueChanged<String> onChangeLocation;

  const _Header({
    required this.selectedLocation,
    required this.onChangeLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.menu, onTap: () {}),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ĐỊA ĐIỂM',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedLocation,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const _Avatar(),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 18,
      backgroundImage: AssetImage('assets/homepageUser/restaurant_img2.jpg'),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepOrange),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final double total;
  final String filter;
  final ValueChanged<String> onFilterChanged;
  final List<double> series;
  final List<String> labels;
  final List<String> tooltips;

  const _RevenueCard({
    required this.total,
    required this.filter,
    required this.onFilterChanged,
    required this.series,
    required this.labels,
    required this.tooltips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng doanh thu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatCurrencyVND(total),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: filter,
                  items: const [
                    DropdownMenuItem(value: 'Hàng ngày', child: Text('Hàng ngày')),
                    DropdownMenuItem(value: 'Hàng tuần', child: Text('Hàng tuần')),
                    DropdownMenuItem(value: 'Hàng tháng', child: Text('Hàng tháng')),
                  ],
                  onChanged: (v) {
                    if (v != null) onFilterChanged(v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {},
                child: const Text('Xem chi tiết'),
              )
            ],
          ),
          const SizedBox(height: 12),
          _LineChart(
            series: series,
            labels: labels,
            tooltips: tooltips,
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final ticks = labels.isNotEmpty ? labels : const <String>['', '', '', '', '', '', '', ''];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ticks
                    .map((t) => Flexible(
                          child: Text(
                            t,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ))
                    .toList(),
              );
            },
          )
        ],
      ),
    );
  }

  // removed per top-level formatCurrencyVND
}

class _LineChart extends StatefulWidget {
  final List<double> series;
  final List<String> labels;
  final List<String> tooltips;
  const _LineChart({required this.series, this.labels = const [], this.tooltips = const []});

  @override
  State<_LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<_LineChart> {
  int _selectedIndex = -1; // -1 => default to last point

  @override
  void didUpdateWidget(covariant _LineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series.length != widget.series.length) {
      _selectedIndex = -1;
    }
  }

  void _updateSelection(Offset localPos, Size size) {
    final s = widget.series;
    if (s.isEmpty) return;
    final clampedX = localPos.dx.clamp(0.0, size.width);
    final ratio = s.length <= 1 ? 0.0 : clampedX / size.width;
    final idx = (ratio * (s.length - 1)).round().clamp(0, s.length - 1);
    if (idx != _selectedIndex) {
      setState(() => _selectedIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return MouseRegion(
            onHover: (event) => _updateSelection(event.localPosition, size),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (d) => _updateSelection(d.localPosition, size),
              onPanUpdate: (d) => _updateSelection(d.localPosition, size),
              onTapDown: (d) => _updateSelection(d.localPosition, size),
              child: CustomPaint(
                painter: _LineChartPainter(
                  series: widget.series,
                  labels: widget.labels,
                  tooltips: widget.tooltips,
                  selectedIndex: _selectedIndex >= 0
                      ? _selectedIndex
                      : (widget.series.isEmpty ? 0 : widget.series.length - 1),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> series;
  final List<String> labels;
  final List<String> tooltips;
  final int selectedIndex;
  _LineChartPainter({required this.series, required this.labels, required this.tooltips, required this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFFF8F9FB)
      ..style = PaintingStyle.fill;
    final borderRadius = 12.0;

    final rrect = RRect.fromRectAndRadius(  
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, bgPaint);

    if (series.isEmpty) return;

    final maxV = series.reduce((a, b) => a > b ? a : b);
    final minV = series.reduce((a, b) => a < b ? a : b);
    final dy = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    final path = Path();
    for (int i = 0; i < series.length; i++) {
      final x = size.width * (i / (series.length - 1));
      final y = size.height - ((series[i] - minV) / dy) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    final sel = selectedIndex.clamp(0, series.length - 1);
    final x = size.width * (sel / (series.length - 1));
    final y = size.height - ((series[sel] - minV) / dy) * size.height;

    final dotPaint = Paint()..color = Colors.deepOrange;
    canvas.drawCircle(Offset(x, y), 5, dotPaint);

    final valueLabel = formatCurrencyVND(series[sel]);
    String period = (tooltips.isNotEmpty && sel < tooltips.length && tooltips[sel].isNotEmpty)
        ? tooltips[sel]
        : ((labels.isNotEmpty && sel < labels.length) ? labels[sel] : '');
    final textPainter = TextPainter(
      text: TextSpan(children: [
        if (period.isNotEmpty)
          const TextSpan(text: '\n'),
        TextSpan(text: valueLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ]),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final labelPadding = 10.0;
    final minLabelWidth = 90.0;
    final labelWidth = (textPainter.width + 22).clamp(minLabelWidth, size.width) as double;
    final labelHeight = textPainter.height + 14;

    final isNearBottom = y > size.height * 0.8;
    final double tooltipTop = (isNearBottom
            ? (y - labelHeight - 12).clamp(6.0, size.height - labelHeight - 6.0)
            : (y + 12).clamp(6.0, size.height - labelHeight - 6.0))
        as double;
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        ((x - labelWidth / 2).clamp(6.0, size.width - labelWidth - 6.0)).toDouble(),
        tooltipTop,
        labelWidth,
        labelHeight,
      ),
      const Radius.circular(8),
    );

    final labelPaint = Paint()..color = Colors.black87;
    canvas.drawRRect(labelRect, labelPaint);

    textPainter.paint(canvas, Offset(
      labelRect.left + labelPadding / 2,
      labelRect.top + (labelHeight - textPainter.height) / 2,
    ));

    if (period.isNotEmpty) {
      final periodPainter = TextPainter(
        text: TextSpan(text: period, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      periodPainter.layout(maxWidth: labelWidth);
      final periodOffset = Offset(
        labelRect.left + (labelWidth - periodPainter.width) / 2,
        labelRect.top + 3,
      );
      periodPainter.paint(canvas, periodOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ReviewsPreview extends StatelessWidget {
  final double rating;
  final int totalReviews;
  const _ReviewsPreview({required this.rating, required this.totalReviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.deepOrange, size: 28),
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: 8),
          Text('Tổng ${totalReviews} đánh giá'),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text('Xem tất cả đánh giá')),
        ],
      ),
    );
  }
}

class _PopularItemsSection extends StatelessWidget {
  const _PopularItemsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Món phổ biến trong tuần',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _PopularItemCard(
                  image: 'assets/homepageUser/burger_img1.jpg',
                  title: 'Burger bò phô mai',
                ),
                SizedBox(width: 12),
                _PopularItemCard(
                  image: 'assets/homepageUser/pizza_img1.webp',
                  title: 'Pizza hải sản',
                ),
                SizedBox(width: 12),
                _PopularItemCard(
                  image: 'assets/homepageUser/restaurant_img1.jpg',
                  title: 'Combo đặc biệt',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularItemCard extends StatelessWidget {
  final String image;
  final String title;
  const _PopularItemCard({required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              image,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return Container(
                  color: const Color(0xFFF5F6FA),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onCenterTap;
  const _BottomBar({required this.onCenterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(icon: Icons.grid_view_rounded, selected: true, onTap: () {}),
          _NavIcon(icon: Icons.menu_rounded, selected: false, onTap: () {}),
          _CenterButton(onTap: onCenterTap),
          _NavIcon(icon: Icons.notifications_none_rounded, selected: false, onTap: () {}),
          _NavIcon(icon: Icons.person_outline_rounded, selected: false, onTap: () {}),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _NavIcon({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.deepOrange : Colors.black54;
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: color),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Colors.deepOrange,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
