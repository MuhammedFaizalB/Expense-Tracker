import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.createdAt,
    this.displayName,
  });

  @override
  List<Object?> get props => [id, email, displayName, createdAt];
}
