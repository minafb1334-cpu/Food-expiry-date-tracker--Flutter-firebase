import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';
import '../providers/food_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;
    final foodProvider = Provider.of<FoodProvider>(context);
    final notifications = foodProvider.getExpiryNotifications(); 

    return Scaffold(
      body: notifications.isEmpty
          ? Center(
              child: Text(
                "No items are expiring soon",
                style: TextStyle(fontSize: fontSize + 2),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final color1 = _hexToColor(notification['color1']!);
                final color2 = _hexToColor(notification['color2']!);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color1, color2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title']!,
                        style: TextStyle(
                          fontSize: fontSize + 3,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['message']!,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Color _hexToColor(String hexCode) {
    return Color(int.parse('FF${hexCode.replaceAll("#", "")}', radix: 16));
  }
}
