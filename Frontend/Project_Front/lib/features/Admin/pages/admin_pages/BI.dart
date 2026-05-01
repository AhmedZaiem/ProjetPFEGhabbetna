import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:authproject/features/Admin/services/BI_Incident_service.dart';
import 'package:authproject/l10n/app_localizations.dart';

class Bi extends StatefulWidget {
  const Bi({super.key});

  @override
  State<Bi> createState() => _BiState();
}

class _BiState extends State<Bi> {
  final service = IncidentBIService();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            Text(t.BI),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.Incident_statistics,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 260,
              child: Row(
                children: [
                  // LINE CHART
                  Expanded(
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: FutureBuilder(
                          future: service.getIncidentsOverTime(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final data = snapshot.data as List;

                            List<FlSpot> spots = [];

                            for (int i = 0; i < data.length; i++) {
                              spots.add(
                                FlSpot(
                                  i.toDouble(),
                                  (data[i]['count'] as num).toDouble(),
                                ),
                              );
                            }

                            return Column(
                              children: [
                                Text(
                                  t.Over_time,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 6),

                                Expanded(
                                  child: LineChart(
                                    LineChartData(
                                      minY: 0,
                                      maxY: 10,

                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: spots,
                                          isCurved: true,
                                          dotData: const FlDotData(show: true),
                                        ),
                                      ],

                                      titlesData: FlTitlesData(
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),

                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),

                                        // ❌ REMOVE const HERE (this fixes your error)
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 2,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 1,
                                            getTitlesWidget: (value, meta) {
                                              int index = value.toInt();

                                              if (index < 0 ||
                                                  index >= data.length) {
                                                return const SizedBox();
                                              }

                                              String rawDate =
                                                  data[index]['date']
                                                      .toString();

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 6,
                                                ),
                                                child: Text(
                                                  rawDate,
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // PIE CHART
                  Expanded(
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: FutureBuilder(
                          future: service.getIncidentsByStatus(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final data = snapshot.data as List;

                            List<PieChartSectionData> sections = data.map((e) {
                              String rawStatus = e['status'].toString();

                              // REMOVE "Status." PREFIX
                              String status = rawStatus.replaceAll(
                                "Status.",
                                "",
                              );

                              Color color;
                              String title;

                              if (status == "accepted") {
                                color = Colors.blue;
                                title = t.admin_accepted_incidents;
                              } else if (status == "not_accepted") {
                                color = Colors.red;
                                title = t.admin_not_accepted_incidents;
                              } else if (status == "pending") {
                                color = Colors.green;
                                title = t.admin_pending_incidents;
                              } else {
                                color = Colors.grey;
                                title = status;
                              }

                              return PieChartSectionData(
                                value: (e['count'] as num).toDouble(),
                                title: "",
                                color: color,
                                radius: 45,
                              );
                            }).toList();

                            return Column(
                              children: [
                                Text(
                                  t.By_status,
                                  style: const TextStyle(fontSize: 14),
                                ),

                                const SizedBox(height: 6),

                                Expanded(
                                  child: PieChart(
                                    PieChartData(sections: sections),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // LEGEND
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: data.map<Widget>((e) {
                                    String rawStatus = e['status'].toString();
                                    String status = rawStatus.replaceAll(
                                      "Status.",
                                      "",
                                    );

                                    Color color;
                                    String title;

                                    if (status == "accepted") {
                                      color = Colors.blue;
                                      title = t.admin_accepted_incidents;
                                    } else if (status == "not_accepted") {
                                      color = Colors.red;
                                      title = t.admin_not_accepted_incidents;
                                    } else if (status == "pending") {
                                      color = Colors.green;
                                      title = t.admin_pending_incidents;
                                    } else {
                                      color = Colors.grey;
                                      title = status;
                                    }

                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          title,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: FutureBuilder(
                          future: service.getIncidentsByRegion(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final data = snapshot.data as List;

                            List<BarChartGroupData> bars = [];

                            for (int i = 0; i < data.length; i++) {
                              bars.add(
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (data[i]['count'] as num).toDouble(),
                                      width: 12,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              children: [
                                Text(
                                  t.By_region,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 6),

                                Expanded(
                                  child: BarChart(
                                    BarChartData(
                                      barGroups: bars,

                                      titlesData: FlTitlesData(
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),

                                        leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),

                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: 1,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              int index = value.toInt();

                                              if (index < 0 ||
                                                  index >= data.length) {
                                                return const SizedBox();
                                              }

                                              return Text(
                                                data[index]['region']
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
