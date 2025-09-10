import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final String productCategory;
  final double price;
  final Color color;

  const ProductCard({
    super.key,
    required this.productName,
    required this.productCategory,
    required this.price,
    this.color = Colors.blueAccent, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, 
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: color,  
        elevation: 5,  
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text(
                productName,
                style: const TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,  
                ),
              ),
              const SizedBox(height: 4),
              
              
              Text(
                productCategory,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,  
                ),
              ),
              const SizedBox(height: 8),

              
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,  
                    fontWeight: FontWeight.bold,
                    color: Colors.white,  
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
