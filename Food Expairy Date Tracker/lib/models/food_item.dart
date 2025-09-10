class FoodItem {
  String _id = '';  
  String name;
  String type;
  DateTime expiryDate;
  String logoUrl;
  String userId; 

  FoodItem({
    String id = '',  
    required this.name,
    required this.type,
    required this.expiryDate,
    required this.logoUrl,
    required this.userId, 
  }) : _id = id;

  
  String get id => _id;

  void setId(String newId) {
    _id = newId;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'expiryDate': expiryDate.toIso8601String(),
      'logoUrl': logoUrl,
      'userId': userId, 
    };
  }

  static FoodItem fromJson(Map<String, dynamic> json, String id) {
    return FoodItem(
      id: id,
      name: json['name'] ?? '',  
      type: json['type'] ?? 'Other',  
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate']) 
          : DateTime.now(),  
      logoUrl: json['logoUrl'] ?? 'assets/food_logos/other.png',  
      userId: json['userId'] ?? '',  
    );
  }
}
