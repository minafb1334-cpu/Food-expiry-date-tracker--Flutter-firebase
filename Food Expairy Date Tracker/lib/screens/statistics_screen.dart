import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  // Mapping singular type to category name used in pie chart
  String normalizeCategory(String rawType) {
    switch (rawType.toLowerCase()) {
      case 'fruit':
        return 'Fruits';
      case 'vegetable':
        return 'Vegetables';
      case 'dairy':
        return 'Dairy';
      case 'snack':
        return 'Snacks';
      default:
        return 'Unknown';
    }
  }

  Future<Map<String, int>> fetchUsageData() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final event = await databaseReference.child('food_items').once();
    final snapshot = event.snapshot;

    Map<String, int> categoryUsage = {
      'Fruits': 0,
      'Vegetables': 0,
      'Dairy': 0,
      'Snacks': 0,
    };

    if (snapshot.exists) {
      final Map<String, dynamic> foodItems =
          Map<String, dynamic>.from(snapshot.value as Map);

      final DateTime now = DateTime.now();
      final DateTime oneWeekLater = now.add(const Duration(days: 7));

      foodItems.forEach((key, value) {
        final item = Map<String, dynamic>.from(value);

        final String rawType = item['type'] ?? '';
        final String expiryStr = item['expiryDate'] ?? '';

        if (rawType.isEmpty || expiryStr.isEmpty) return;

        final String category = normalizeCategory(rawType);

        try {
          final DateTime expiryDate = DateTime.parse(expiryStr);

          // Count items expiring within 7 days
          if (expiryDate.isBefore(oneWeekLater)) {
            categoryUsage[category] = categoryUsage[category]! + 1;
          }
        } catch (e) {
          print('Date parsing error: $e');
        }
      });
    }

    return categoryUsage;
  }

  Widget _buildInsightCard({
    required String title,
    required int count,
    required Color color,
    required double fontSize,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              width: 100,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: count.toDouble(),
                      title: '$count',
                      color: color,
                      radius: 35,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 1, 
                      title: '',
                      color: Colors.grey.shade300,
                      radius: 35,
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: 20,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Expiring soon: $count item(s)', style: TextStyle(fontSize: fontSize)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    return Scaffold(
      body: FutureBuilder<Map<String, int>>(
        future: fetchUsageData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final usage = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Items Expiring Soon by Category',
                style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildInsightCard(title: 'Fruits', count: usage['Fruits']!, color: Colors.orange, fontSize: fontSize),
              _buildInsightCard(title: 'Vegetables', count: usage['Vegetables']!, color: Colors.green, fontSize: fontSize),
              _buildInsightCard(title: 'Dairy', count: usage['Dairy']!, color: Colors.blueAccent, fontSize: fontSize),
              _buildInsightCard(title: 'Snacks', count: usage['Snacks']!, color: Colors.purple, fontSize: fontSize),
            ],
          );
        },
      ),
    );
  }
}
