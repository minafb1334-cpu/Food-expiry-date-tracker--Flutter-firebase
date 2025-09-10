import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/font_size_provider.dart';
import 'login_screen.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = 'English';
  final List<String> languages = ['English', 'Arabic', 'French'];
  bool notificationsEnabled = true;
  int _selectedRating = 0;

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rate the App"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("How would you rate your experience?"),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _selectedRating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.orange,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Thanks for rating $_selectedRating stars"),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontProvider = Provider.of<FontSizeProvider>(context);
    bool isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: Text("Dark Mode", style: TextStyle(fontSize: fontProvider.fontSize)),
              value: isDark,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text("Notifications", style: TextStyle(fontSize: fontProvider.fontSize)),
              value: notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  notificationsEnabled = val;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Language', style: TextStyle(fontSize: fontProvider.fontSize)),
              trailing: DropdownButton<String>(
                value: selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value!;
                  });
                },
                items: languages.map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang));
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text("Font Size", style: TextStyle(fontSize: fontProvider.fontSize)),
            Slider(
              value: fontProvider.fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 6,
              label: fontProvider.fontSize.toStringAsFixed(0),
              onChanged: (value) => fontProvider.setFontSize(value),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text("Help Center", style: TextStyle(fontSize: fontProvider.fontSize)),
              leading: const Icon(Icons.help_outline),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Help Center"),
                    content: const Text("For support, contact us at support@example.com."),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Rate App", style: TextStyle(fontSize: fontProvider.fontSize)),
              leading: const Icon(Icons.star_rate),
              onTap: _showRatingDialog,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out")),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: fontProvider.fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
