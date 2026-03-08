import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class RestaurantDetailPage extends StatelessWidget {
  final String restaurantId;
  const RestaurantDetailPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('تفاصيل المطعم')),
      body: Center(child: Text('مطعم: $restaurantId')),
    );
  }
}
