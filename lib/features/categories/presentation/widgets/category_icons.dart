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
  'groups': Icons.groups_outlined,
  'theater_comedy': Icons.theater_comedy_outlined,
  'chair': Icons.chair_outlined,
  'checkroom': Icons.checkroom_outlined,
  'spa': Icons.spa_outlined,
  'redeem': Icons.redeem_outlined,
  'credit_card': Icons.credit_card_outlined,
  'local_grocery_store': Icons.local_grocery_store_outlined,
  'water_drop': Icons.water_drop_outlined,
  'phone_android': Icons.phone_android_outlined,
  'local_gas_station': Icons.local_gas_station_outlined,
  'devices': Icons.devices_outlined,
  'subscriptions': Icons.subscriptions_outlined,
  'fitness_center': Icons.fitness_center_outlined,

  'two_wheeler': Icons.two_wheeler_outlined,
  'pedal_bike': Icons.pedal_bike_outlined,
  'electric_car': Icons.electric_car_outlined,
  'car_repair': Icons.car_repair_outlined,
};

IconData resolveCategoryIcon(String iconName) =>
    categoryIconMap[iconName] ?? Icons.category_outlined;
