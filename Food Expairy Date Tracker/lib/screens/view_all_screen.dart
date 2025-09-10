import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../models/food_item.dart';
import '../providers/font_size_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Provider.of<FoodProvider>(context, listen: false).fetchFoodItems(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in to view food items')),
      );
    }

    return Scaffold(
      body: foodProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : foodProvider.items.isEmpty
              ? Center(child: Text('No food items found'))
              : ListView.builder(
                  itemCount: foodProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = foodProvider.items[index];
                    return ListTile(
                      title: Row(
                        children: [
                          Image.network(
                            item.logoUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 10),
                          Text(
                            item.name,
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${item.type} - Expires: ${item.expiryDate.toLocal().toString().split(" ")[0]}',
                        style: TextStyle(fontSize: fontSize),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              _showEditDialog(context, index, item);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              foodProvider.deleteItem(index);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  void _showEditDialog(BuildContext context, int index, FoodItem oldItem) {
    final nameController = TextEditingController(text: oldItem.name);
    String selectedType = oldItem.type;
    DateTime? selectedDate = oldItem.expiryDate;
    String selectedLogoUrl = oldItem.logoUrl;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController),
                  DropdownButton<String>(
                    value: selectedType,
                    onChanged: (val) => setState(() => selectedType = val!),
                    items: ['Fruit', 'Vegetable', 'Meat', 'Dairy', 'Snack', 'Drink', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.calendar_today),
                    label: Text(selectedDate == null
                        ? 'Pick Expiration Date'
                        : selectedDate.toString().split(" ")[0]),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate!,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                  TextField(
                    controller: TextEditingController(text: selectedLogoUrl),
                    decoration: InputDecoration(labelText: 'Logo URL'),
                    onChanged: (val) => setState(() => selectedLogoUrl = val),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Provider.of<FoodProvider>(context, listen: false).updateItem(
                    index,
                    FoodItem(
                      name: nameController.text,
                      type: selectedType,
                      expiryDate: selectedDate!,
                      logoUrl: selectedLogoUrl,
                      userId: user.uid,
                    ),
                  );
                }
                Navigator.of(ctx).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
