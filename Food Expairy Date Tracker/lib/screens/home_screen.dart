import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../providers/font_size_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_flutter_app/widgets/product_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _foodTypes = ['Fruit', 'Vegetable', 'Meat', 'Dairy', 'Snack', 'Drink', 'Other'];
  String _selectedType = 'Fruit';
  DateTime? _selectedDate;

  void _openAddItemBottomSheet(BuildContext context) {
    double fontSize = Provider.of<FontSizeProvider>(context, listen: false).fontSize;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Wrap(
          children: [
            _buildTextField(fontSize),
            const SizedBox(height: 10),
            _buildDropdown(fontSize),
            const SizedBox(height: 10),
            _buildDatePicker(fontSize),
            const SizedBox(height: 20),
            _buildAddItemButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(double fontSize) {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(labelText: 'Food Name'),
      style: TextStyle(fontSize: fontSize),
    );
  }

  Widget _buildDropdown(double fontSize) {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      items: _foodTypes.map((type) {
        return DropdownMenuItem<String>(value: type, child: Text(type, style: TextStyle(fontSize: fontSize)));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
        });
      },
      decoration: const InputDecoration(labelText: 'Food Type'),
    );
  }

  Widget _buildDatePicker(double fontSize) {
    return ListTile(
      title: Text(
        _selectedDate == null
            ? 'Select Expiration Date'
            : 'Expires on: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
        style: TextStyle(fontSize: fontSize),
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: _pickDate,
    );
  }

  Widget _buildAddItemButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _addFoodItem(context);
        Navigator.pop(context);
      },
      label: const Text('Add Item', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _addFoodItem(BuildContext context) async {
    String name = _nameController.text.trim();
    DateTime? expiryDate = _selectedDate;

    if (name.isNotEmpty && expiryDate != null) {
      final logoUrl = _getLogoUrl(_selectedType);

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
        return;
      }

      final newItem = FoodItem(
        name: name,
        type: _selectedType,
        expiryDate: expiryDate,
        logoUrl: logoUrl,
        userId: user.uid,
      );

      DatabaseReference ref = FirebaseDatabase.instance.ref('food_items');

      await ref.push().set(newItem.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added: $name ($_selectedType), expires on ${expiryDate.toLocal().toString().split(" ")[0]}')),
      );

      _nameController.clear();
      setState(() {
        _selectedDate = null;
        _selectedType = 'Fruit';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getLogoUrl(String foodType) {
    switch (foodType) {
      case 'Fruit': return 'assets/food_logos/fruit.png';
      case 'Vegetable': return 'assets/food_logos/vegetables.png';
      case 'Meat': return 'assets/food_logos/meat.png';
      case 'Dairy': return 'assets/food_logos/dairy.png';
      case 'Snack': return 'assets/food_logos/snack.png';
      case 'Drink': return 'assets/food_logos/drink.png';
      case 'Other':
      default: return 'assets/food_logos/other.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Welcome to Food Tracker', style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold)),
            ),
            carousel.CarouselSlider(
              items: [
                _buildSlide('Food Tracker', 'Expirations', Icons.fastfood, 0.4, fontSize),
                _buildSlide('Summary', 'what’s left', Icons.bar_chart, 0.7, fontSize),
                _buildSlide('Wasted Food', 'Cut down waste', Icons.delete_forever, 0.2, fontSize),
              ],
              options: carousel.CarouselOptions(
                height: 250,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                viewportFraction: 0.9,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Expiring Soon', style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance.ref('food_items').orderByChild('expiryDate').onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final data = snapshot.data!.snapshot.value;
                  if (data is Map<dynamic, dynamic>) {
                    List<FoodItem> foodItems = data.entries.map((entry) {
                      return FoodItem.fromJson(Map<String, dynamic>.from(entry.value), entry.key);
                    }).toList();

                    return Column(
                      children: _buildExpiringSoonTaskbars(foodItems, fontSize),
                    );
                  }
                }

                return const Center(child: Text("No data available"));
              },
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Products to Buy', style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold)),
            ),
            _buildProductList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddItemBottomSheet(context),
        backgroundColor: const Color.fromARGB(255, 253, 199, 51),
        child: const Icon(Icons.add, color: Color.fromARGB(255, 4, 1, 22)),
      ),
    );
  }

  static Widget _buildSlide(String title, String description, IconData icon, double progress, double fontSize) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.deepPurple),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: fontSize - 2)),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 4),
            Text('${(progress * 100).round()}% completed', style: TextStyle(fontSize: fontSize - 2)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExpiringSoonTaskbars(List<FoodItem> foodItems, double fontSize) {
    List<Widget> widgets = [];
    DateTime now = DateTime.now();

    for (var item in foodItems) {
      if (item.expiryDate.isBefore(now.add(const Duration(days: 7)))) {
        int daysLeft = item.expiryDate.difference(now).inDays;
        double progress = (7 - daysLeft) / 7;

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.name} (${item.type})', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
                const SizedBox(height: 2),
                Text('${daysLeft < 0 ? 0 : daysLeft} days left', style: TextStyle(fontSize: fontSize - 2)),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }



Widget _buildProductList() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductCard(
          productName: 'Milk',
          productCategory: 'Dairy',
          price: 10.99,
          color: const Color.fromARGB(255, 141, 207, 238),
        ),
        ProductCard(
          productName: 'Apple',
          productCategory: 'Fruit',
          price: 3.99,
          color: const Color.fromARGB(255, 228, 144, 165),
        ),
        ProductCard(
          productName: 'Bread',
          productCategory: 'Snack',
          price: 2.99,
          color: const Color.fromARGB(255, 221, 130, 206),
        ),
      ],
    ),
  );
}

}