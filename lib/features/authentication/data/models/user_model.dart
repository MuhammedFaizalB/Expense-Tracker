import 'package:expense_tracker/features/authentication/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.createdAt,
    super.displayName,
  });

  factory UserModel.fromSupabase(sb.User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  factory UserModel.fromProfileRow(Map<String, dynamic> row) {
    return UserModel(
      id: row['id'] as String,
      email: row['email'] as String,
      displayName: row['display_name'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
