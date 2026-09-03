import 'package:equatable/equatable.dart';

enum CategoryType { income, expense }

class CategoryEntity extends Equatable {
  final String id;
  final String? userId;
  final String name;
  final CategoryType type;
  final String icon;
  final int color;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
  });

  CategoryEntity copyWith({
    String? name,
    CategoryType? type,
    String? icon,
    int? color,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id,
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    type,
    icon,
    color,
    isDefault,
    sortOrder,
    createdAt,
    updatedAt,
  ];
}
