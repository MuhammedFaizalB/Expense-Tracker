import 'package:flutter/material.dart';

const Map<String, IconData> categoryIconMap = {
  'restaurant': Icons.restaurant_outlined,
  'directions_car': Icons.directions_car_outlined,
  'shopping_bag': Icons.shopping_bag_outlined,
  'receipt_long': Icons.receipt_long_outlined,
  'home': Icons.home_outlined,
  'movie': Icons.movie_outlined,
  'favorite': Icons.favorite_outline,
  'school': Icons.school_outlined,
  'flight': Icons.flight_outlined,
  'payments': Icons.payments_outlined,
  'work': Icons.work_outline,
  'store': Icons.store_outlined,
  'trending_up': Icons.trending_up,
  'card_giftcard': Icons.card_giftcard_outlined,
  'category': Icons.category_outlined,
};

IconData resolveCategoryIcon(String iconName) =>
    categoryIconMap[iconName] ?? Icons.category_outlined;
