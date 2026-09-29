import 'package:expense_tracker/features/lending/domain/entities/lending_contact_entity.dart';

class LendingContactModel extends LendingContactEntity {
  const LendingContactModel({
    required super.id,
    required super.name,
    required super.createdAt,
  });

  factory LendingContactModel.fromJson(Map<String, dynamic> json) {
    return LendingContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
