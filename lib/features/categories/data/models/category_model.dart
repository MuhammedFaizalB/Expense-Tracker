import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.type,
    required super.icon,
    required super.color,
    required super.isDefault,
    required super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
    super.userId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      type: json['type'] == 'income'
          ? CategoryType.income
          : CategoryType.expense,
      icon: json['icon'] as String,
      color: json['color'] as int,
      isDefault: json['is_default'] as bool,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'name': name,
    'type': type == CategoryType.income ? 'income' : 'expense',
    'icon': icon,
    'color': color,
    'sort_order': sortOrder,
  };
}
