import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodProvider with ChangeNotifier {
  final List<FoodItem> _items = [];
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref().child('food_items');
  bool _isLoading = false;  
  bool get isLoading => _isLoading; 

  List<FoodItem> get items => [..._items];

  Future<void> fetchFoodItems(String userId) async {
    _isLoading = true;
    notifyListeners(); 

    try {
      final DatabaseEvent snapshot = await _databaseReference
          .orderByChild('userId')
          .equalTo(userId)
          .once();

      if (snapshot.snapshot.value is Map) {
        final Map<dynamic, dynamic> foodItemsMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        _items.clear();

        foodItemsMap.forEach((id, data) {
          final foodItem = FoodItem.fromJson(Map<String, dynamic>.from(data), id);
          _items.add(foodItem);
        });
      } else {
        _items.clear(); 
      }
    } catch (e) {
      print('Error fetching food items: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  Future<void> addItem(FoodItem item) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final newRef = _databaseReference.push();
      final itemJson = item.toJson()..['userId'] = user.uid;

      await newRef.set(itemJson);
      item.setId(newRef.key!);
      _items.add(item);
      notifyListeners();
    } catch (e) {
      print('Error adding food item: $e');
    }
  }

  Future<void> updateItem(int index, FoodItem newItem) async {
    try {
      final foodItem = _items[index];
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || foodItem.userId != user.uid) {
        throw Exception('User not authorized to update this item');
      }

      await _databaseReference.child(foodItem.id).update(newItem.toJson());
      newItem.setId(foodItem.id);
      _items[index] = newItem;
      notifyListeners();
    } catch (e) {
      print('Error updating food item: $e');
    }
  }

  Future<void> deleteItem(int index) async {
    try {
      final foodItem = _items[index];
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || foodItem.userId != user.uid) {
        throw Exception('User not authorized to delete this item');
      }

      await _databaseReference.child(foodItem.id).remove();
      _items.removeAt(index);
      notifyListeners();
    } catch (e) {
      print('Error deleting food item: $e');
    }
  }

  List<Map<String, String>> getExpiryNotifications() {
    final now = DateTime.now();
    final List<Map<String, String>> notifications = [];

    for (var item in _items) {
      final daysLeft = item.expiryDate.difference(now).inDays;

      if (daysLeft >= 0 && daysLeft <= 3) {
        String title;
        if (daysLeft == 0) {
          title = '${item.name} expires today!';
        } else if (daysLeft == 1) {
          title = '${item.name} expires in 1 day!';
        } else {
          title = '${item.name} expires in $daysLeft days!';
        }

        notifications.add({
          'title': title,
          'message': 'Check or use it soon!',
          'color1': '#3a63e8',
          'color2': '#9e93f5',
        });
      }
    }

    return notifications;
  }
}
