import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';

class FoodCubit extends Cubit<List<FoodItem>> {
  final FirebaseFirestore _firestore;

  FoodCubit(this._firestore) : super([]);

  Future<void> addFoodItem(FoodItem foodItem) async {
    try {
      var docRef = await _firestore.collection('food_items').add(foodItem.toJson());

      foodItem.setId(docRef.id);

      emit([...state, foodItem]);
    } catch (e) {
      print('Error adding food item: $e');
    }
  }

  Future<void> loadFoodItems() async {
    try {
      final snapshot = await _firestore.collection('food_items').get();
      final foodItems = snapshot.docs
          .map((doc) {
            var foodItem = FoodItem.fromJson(doc.data(), doc.id);  
            return foodItem;
          })
          .toList();
      emit(foodItems);
    } catch (e) {
      print('Error loading food items: $e');
    }
  }

  Future<void> deleteFoodItem(String docId) async {
    try {
      await _firestore.collection('food_items').doc(docId).delete();

      emit(state.where((item) => item.id != docId).toList());
    } catch (e) {
      print('Error deleting food item: $e');
    }
  }
}
