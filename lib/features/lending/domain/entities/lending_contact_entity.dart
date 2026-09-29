import 'package:equatable/equatable.dart';

class LendingContactEntity extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;

  const LendingContactEntity({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, createdAt];
}
