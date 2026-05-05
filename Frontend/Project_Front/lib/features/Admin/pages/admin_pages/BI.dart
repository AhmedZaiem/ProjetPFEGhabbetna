import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:authproject/features/Admin/services/BI_Incident_service.dart';
import 'package:authproject/l10n/app_localizations.dart';

// ─── helpers ────────────────────────────────────────────────────────────────

Color _statusColor(String status) {
  switch (status) {
    case 'accepted':
      return const Color(0xFF3B82F6); // blue
    case 'not_accepted':
      return const Color(0xFFEF4444); // red
    case 'pending':
      return const Color(0xFF10B981); // green
    default:
      return const Color(0xFF9CA3AF); // grey
  }
}

String _cleanStatus(String raw) => raw.replaceAll('Status.', '');

// ─── widget ─────────────────────────────────────────────────────────────────

class Bi extends StatefulWidget {
  const Bi({super.key});

  @override
  State<Bi> createState() => _BiState();
}

class _BiState extends State<Bi> {
  final service = IncidentBIService();

  // accent palette used across cards
  static const Color _accent1 = Color(0xFF6366F1); // indigo  – line chart
  static const Color _accent2 = Color(0xFF8B5CF6); // violet  – pie chart
  static const Color _accent3 = Color(0xFF0EA5E9); // sky     – bar chart

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/logoApp.jpeg', height: 36),
            ),
            const SizedBox(width: 12),
            Text(
              t.BI,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),

      // ── scrollable body ──────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // page header
            Text(
              t.Incident_statistics,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),

            // ── Line chart ─────────────────────────────────────────────────
            _ChartCard(
              title: t.Over_time,
              subtitle: t.Incident_reported_by_day,
              accentColor: _accent1,
              icon: Icons.show_chart_rounded,
              child: FutureBuilder(
                future: service.getIncidentsOverTime(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return _ErrorState();
                  if (!snapshot.hasData) return _Loading();

                  final data = snapshot.data as List;
                  if (data.isEmpty) return _EmptyState();

                  final maxY = data
                      .map((e) => (e['count'] as num).toDouble())
                      .fold(0.0, (a, b) => a > b ? a : b);

                  final spots = [
                    for (int i = 0; i < data.length; i++)
                      FlSpot(
                        i.toDouble(),
                        (data[i]['count'] as num).toDouble(),
                      ),
                  ];

                  return LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: (maxY + 2).ceilToDouble(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: _accent1,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, pct, bar, idx) =>
                                FlDotCirclePainter(
                                  radius: 3.5,
                                  color: _accent1,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: _accent1.withOpacity(0.08),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: _niceInterval(maxY),
                            getTitlesWidget: (v, _) => Text(
                              v.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: _bottomInterval(data.length),
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= data.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _shortDate(data[i]['date'].toString()),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Pie + Bar side by side (wrap on narrow screens) ─────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth > 560;
                final gap = 16.0;
                final cardW = twoCol
                    ? (constraints.maxWidth - gap) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    // PIE
                    SizedBox(
                      width: cardW,
                      child: _ChartCard(
                        title: t.By_status,
                        subtitle: t.Distribution_by_resolution_status,
                        accentColor: _accent2,
                        icon: Icons.donut_large_rounded,
                        chartHeight: 220,
                        child: FutureBuilder(
                          future: service.getIncidentsByStatus(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return _ErrorState();
                            if (!snapshot.hasData) return _Loading();

                            final data = snapshot.data as List;
                            if (data.isEmpty) return _EmptyState();

                            final sections = data.map((e) {
                              final status = _cleanStatus(
                                e['status'].toString(),
                              );
                              return PieChartSectionData(
                                value: (e['count'] as num).toDouble(),
                                title: '${(e['count'] as num).toInt()}',
                                titleStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                color: _statusColor(status),
                                radius: 55,
                              );
                            }).toList();

                            return Column(
                              children: [
                                SizedBox(
                                  height: 170,
                                  child: PieChart(
                                    PieChartData(
                                      sections: sections,
                                      sectionsSpace: 3,
                                      centerSpaceRadius: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _Legend(data: data, t: t),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // BAR
                    SizedBox(
                      width: cardW,
                      child: _ChartCard(
                        title: t.By_region,
                        subtitle: t.Incident_grouped_by_region,
                        accentColor: _accent3,
                        icon: Icons.bar_chart_rounded,
                        chartHeight: 220,
                        child: FutureBuilder(
                          future: service.getIncidentsByRegion(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return _ErrorState();
                            if (!snapshot.hasData) return _Loading();

                            final data = snapshot.data as List;
                            if (data.isEmpty) return _EmptyState();

                            final maxY = data
                                .map((e) => (e['count'] as num).toDouble())
                                .fold(0.0, (a, b) => a > b ? a : b);

                            final bars = [
                              for (int i = 0; i < data.length; i++)
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (data[i]['count'] as num).toDouble(),
                                      width: 14,
                                      color: _accent3,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                            ];

                            return BarChart(
                              BarChartData(
                                maxY: (maxY + 2).ceilToDouble(),
                                barGroups: bars,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (_) => FlLine(
                                    color: Colors.grey.shade200,
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      interval: _niceInterval(maxY),
                                      getTitlesWidget: (v, _) => Text(
                                        v.toInt().toString(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 36,
                                      getTitlesWidget: (v, _) {
                                        final i = v.toInt();
                                        if (i < 0 || i >= data.length) {
                                          return const SizedBox();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Text(
                                            data[i]['region'].toString(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.grey.shade600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // ── TOP FORESTS & AGENTS ─────────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth > 560;
                final gap = 16.0;
                final cardW = twoCol
                    ? (constraints.maxWidth - gap) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    // 🌲 TOP FORESTS
                    SizedBox(
                      width: cardW,
                      child: _ChartCard(
                        title: t.top_forests,
                        subtitle: t.Most_incidents_by_forest,
                        accentColor: Colors.green,
                        icon: Icons.park_rounded,
                        chartHeight: 220,
                        child: FutureBuilder(
                          future: service.getTopForests(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return _ErrorState();
                            if (!snapshot.hasData) return _Loading();

                            final data = snapshot.data as List;
                            if (data.isEmpty) return _EmptyState();

                            final maxY = data
                                .map((e) => (e['count'] as num).toDouble())
                                .fold(0.0, (a, b) => a > b ? a : b);

                            return BarChart(
                              BarChartData(
                                maxY: (maxY + 2).ceilToDouble(),
                                barGroups: [
                                  for (int i = 0; i < data.length; i++)
                                    BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: (data[i]['count'] as num)
                                              .toDouble(),
                                          width: 14,
                                          color: Colors.green,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                        ),
                                      ],
                                    ),
                                ],
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      interval: _niceInterval(maxY),
                                      getTitlesWidget: (v, _) => Text(
                                        v.toInt().toString(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 36,
                                      getTitlesWidget: (v, _) {
                                        final i = v.toInt();
                                        if (i < 0 || i >= data.length) {
                                          return const SizedBox();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Text(
                                            'Forest ${data[i]['forest_id']}',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.grey.shade600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 👤 TOP AGENTS
                    SizedBox(
                      width: cardW,
                      child: _ChartCard(
                        title: t.top_agents_stat,
                        subtitle: t.Most_active_reporters,
                        accentColor: Colors.orange,
                        icon: Icons.person_rounded,
                        chartHeight: 220,
                        child: FutureBuilder(
                          future: service.getTopAgents(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return _ErrorState();
                            if (!snapshot.hasData) return _Loading();

                            final data = snapshot.data as List;
                            if (data.isEmpty) return _EmptyState();

                            final maxY = data
                                .map((e) => (e['count'] as num).toDouble())
                                .fold(0.0, (a, b) => a > b ? a : b);

                            return BarChart(
                              BarChartData(
                                maxY: (maxY + 2).ceilToDouble(),
                                barGroups: [
                                  for (int i = 0; i < data.length; i++)
                                    BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: (data[i]['count'] as num)
                                              .toDouble(),
                                          width: 14,
                                          color: Colors.orange,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                        ),
                                      ],
                                    ),
                                ],
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      interval: _niceInterval(maxY),
                                      getTitlesWidget: (v, _) => Text(
                                        v.toInt().toString(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 36,
                                      getTitlesWidget: (v, _) {
                                        final i = v.toInt();
                                        if (i < 0 || i >= data.length) {
                                          return const SizedBox();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Text(
                                            "User ${data[i]['user_id']}",
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.grey.shade600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── axis helpers ───────────────────────────────────────────────────────────

  /// Pick a round interval for Y axis based on the max value
  static double _niceInterval(double maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 20) return 2;
    if (maxY <= 50) return 5;
    if (maxY <= 100) return 10;
    return (maxY / 5).ceilToDouble();
  }

  /// Show at most ~6 labels on the bottom axis regardless of data size
  static double _bottomInterval(int length) {
    if (length <= 7) return 1;
    return (length / 6).ceilToDouble();
  }

  /// Shorten "2024-01-15" → "Jan 15"
  static String _shortDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}';
    } catch (_) {
      // fallback: return last 5 chars e.g. "01-15"
      return raw.length > 5 ? raw.substring(raw.length - 5) : raw;
    }
  }
}

// ─── reusable chart card ────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.child,
    this.chartHeight = 260,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final Widget child;
  final double chartHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 12),

          // chart area
          SizedBox(
            height: chartHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 12, 8),
              child: child,
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── pie chart legend ────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend({required this.data, required this.t});

  final List data;
  final AppLocalizations t;

  String _label(String status) {
    switch (status) {
      case 'accepted':
        return t.admin_accepted_incidents;
      case 'not_accepted':
        return t.admin_not_accepted_incidents;
      case 'pending':
        return t.admin_pending_incidents;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: data.map<Widget>((e) {
        final status = _cleanStatus(e['status'].toString());
        final color = _statusColor(status);
        final label = _label(status);
        final count = (e['count'] as num).toInt();

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              '$label ($count)',
              style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─── micro state widgets ─────────────────────────────────────────────────────

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(strokeWidth: 2));
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_rounded, size: 36, color: Colors.grey.shade300),
        const SizedBox(height: 8),
        Text(
          'No data yet',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wifi_off_rounded, size: 36, color: Colors.red.shade200),
        const SizedBox(height: 8),
        Text(
          'Failed to load',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    ),
  );
}
