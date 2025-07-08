import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatisticTab extends StatefulWidget {
  final List<Booking> bookings;

  const StatisticTab({Key? key, required this.bookings}) : super(key: key);

  @override
  State<StatisticTab> createState() => _StatisticTabState();
}

class _StatisticTabState extends State<StatisticTab> {
  bool showPie = true;
  bool showBar = true;
  bool showLine = true;

  int getTotalAmount() {
    return widget.bookings.fold(0, (sum, b) => sum + b.totalPrice);
  }

  int getCountByStatus(String status) {
    return widget.bookings.where((b) => b.statusBooking == status).length;
  }

  @override
  Widget build(BuildContext context) {
    final bookings = widget.bookings;
    final total = getTotalAmount();
    final confirmed = getCountByStatus('confirmed');
    final pending = getCountByStatus('pending');
    final cancelled = getCountByStatus('cancelled');

    final t = AppLocalizations.of(context)!;

    final appOrange = Color(0xFFF36C21);

    // Thống kê tuyến xe đi nhiều nhất
    String mostRoute = t.statNoData;
    int mostRouteCount = 0;
    final Map<String, int> routeCount = {};
    for (var b in bookings) {
      if (b.seats.isNotEmpty && b.seats[0].vehicle?.trip?.nameTrip != null) {
        final route = b.seats[0].vehicle!.trip!.nameTrip!;
        routeCount[route] = (routeCount[route] ?? 0) + 1;
        if (routeCount[route]! > mostRouteCount) {
          mostRoute = route;
          mostRouteCount = routeCount[route]!;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mostRouteCount > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: appOrange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions_bus, color: appOrange, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.statMostRoute, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground)),
                          Text(mostRoute, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onBackground)),
                        ],
                      ),
                    ),
                    Text('$mostRouteCount ${t.statMostRouteCount}', style: TextStyle(fontWeight: FontWeight.bold, color: appOrange)),
                  ],
                ),
              ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                StatisticCard(title: t.statTotalTicket, value: '${bookings.length}', icon: Icons.confirmation_number),
                StatisticCard(title: t.statTotalMoney, value: '${NumberFormat("#,###", "vi_VN").format(total)} đ', icon: Icons.monetization_on),
                StatisticCard(title: t.statConfirmed, value: '$confirmed', icon: Icons.check_circle_outline),
                StatisticCard(title: t.statPending, value: '$pending', icon: Icons.hourglass_empty),
              ],
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => setState(() => showPie = !showPie),
              child: Row(
                children: [
                  Text(t.statPieTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: showPie ? appOrange : Theme.of(context).colorScheme.onBackground)),
                  const SizedBox(width: 8),
                  Icon(showPie ? Icons.expand_less : Icons.expand_more, color: appOrange),
                ],
              ),
            ),
            if (showPie) ...[
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.3,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            value: confirmed.toDouble(),
                            title: confirmed > 0 ? t.statConfirmed : '',
                            color: Colors.green,
                            titleStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                            radius: confirmed >= pending && confirmed >= cancelled ? 60 : 50,
                            showTitle: confirmed > 0,
                            badgeWidget: null,
                            badgePositionPercentageOffset: .98,
                          ),
                          PieChartSectionData(
                            value: pending.toDouble(),
                            title: pending > 0 ? t.statPending : '',
                            color: Colors.orange,
                            titleStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                            radius: pending > confirmed && pending >= cancelled ? 60 : 50,
                            showTitle: pending > 0,
                            badgeWidget: null,
                            badgePositionPercentageOffset: .98,
                          ),
                          PieChartSectionData(
                            value: cancelled.toDouble(),
                            title: cancelled > 0 ? t.statCancelled : '',
                            color: Colors.red,
                            titleStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                            radius: cancelled > confirmed && cancelled > pending ? 60 : 50,
                            showTitle: cancelled > 0,
                            badgeWidget: null,
                            badgePositionPercentageOffset: .98,
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Tổng vé', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7))),
                            Text('${bookings.length}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: appOrange)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => setState(() => showBar = !showBar),
              child: Row(
                children: [
                  Text(t.statBarTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: showBar ? appOrange : Theme.of(context).colorScheme.onBackground)),
                  const SizedBox(width: 8),
                  Icon(showBar ? Icons.expand_less : Icons.expand_more, color: appOrange),
                ],
              ),
            ),
            if (showBar) ...[
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.7,
                child: MonthlyCostBarChart(bookings: bookings),
              ),
            ],
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => setState(() => showLine = !showLine),
              child: Row(
                children: [
                  Text(t.statLineTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: showLine ? appOrange : Theme.of(context).colorScheme.onBackground)),
                  const SizedBox(width: 8),
                  Icon(showLine ? Icons.expand_less : Icons.expand_more, color: appOrange),
                ],
              ),
            ),
            if (showLine) ...[
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.7,
                child: MonthlyTicketLineChart(bookings: bookings),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatisticCard({super.key, required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appOrange = Color(0xFFF36C21);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? appOrange.withOpacity(0.13) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(isDark ? 0.08 : 0.2),
            blurRadius: 8, // độ mờ của bóng
            offset: const Offset(0, 4), // vị trí của bóng, đổ xuống dưới
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: appOrange),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}

// biểu đồ cột thống kê tổng tiền mỗi tháng
class MonthlyCostBarChart extends StatelessWidget {
  final List<Booking> bookings;
  const MonthlyCostBarChart({Key? key, required this.bookings}) : super(key: key);

  List<double> getMonthlyTotals() {
    final now = DateTime.now();
    List<double> totals = List.filled(12, 0);
    for (var b in bookings) {
      final date = b.getTravelDate();
      if (date != null && date.year == now.year && b.totalPrice != null) {
        totals[date.month - 1] += b.totalPrice!.toDouble();
      } // tính tổng tiền mỗi tháng
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final monthlyTotals = getMonthlyTotals();
    final maxY = (monthlyTotals.reduce((a, b) => a > b ? a : b) / 1000).ceil() * 1000.0 + 1000;
    final appOrange = Color(0xFFF36C21);
    return BarChart(// tạo biểu đồ cột
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY : 1000,
        barTouchData: BarTouchData(enabled: true), // cho phép tương tác với biểu đồ
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value % 2000 == 0) {
                  return Text(NumberFormat.compact(locale: 'vi_VN').format(value));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final month = value.toInt() + 1;
                if (month >= 1 && month <= 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('$month', style: const TextStyle(fontSize: 12)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        barGroups: List.generate(12, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: monthlyTotals[i], // giá trị của cột
                color: appOrange,
                width: 18,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class MonthlyTicketLineChart extends StatelessWidget {
  final List<Booking> bookings;
  const MonthlyTicketLineChart({Key? key, required this.bookings}) : super(key: key);

  List<int> getMonthlyCounts() {
    final now = DateTime.now();
    List<int> counts = List.filled(12, 0);
    for (var b in bookings) {
      final date = b.getTravelDate();
      if (date != null && date.year == now.year) {
        counts[date.month - 1]++;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final monthlyCounts = getMonthlyCounts();
    final maxY = (monthlyCounts.reduce((a, b) => a > b ? a : b)).toDouble() + 1;
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY > 1 ? maxY : 5,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final month = value.toInt() + 1;
                if (month >= 1 && month <= 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('$month', style: const TextStyle(fontSize: 12)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
            spots: List.generate(12, (i) => FlSpot(i.toDouble(), monthlyCounts[i].toDouble())),
          ),
        ],
      ),
    );
  }
}
