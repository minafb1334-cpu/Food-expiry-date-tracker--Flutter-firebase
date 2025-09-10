import 'package:equatable/equatable.dart';
import '../models/food_item.dart';


abstract class FoodCubitState extends Equatable {
  const FoodCubitState();

  @override
  List<Object?> get props => [];
}

class FoodCubitInitial extends FoodCubitState {}

class FoodCubitLoading extends FoodCubitState {}

class FoodCubitSuccess extends FoodCubitState {
  final List<FoodItem> foodItems;

  const FoodCubitSuccess({required this.foodItems});

  @override
  List<Object?> get props => [foodItems];
}

class FoodCubitFailure extends FoodCubitState {
  final String error;

  const FoodCubitFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
