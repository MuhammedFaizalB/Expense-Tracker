part of 'category_bloc.dart';

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class CategoryLoadRequested extends CategoryEvent {
  const CategoryLoadRequested();
}

class CategoryAdded extends CategoryEvent {
  final String name;
  final CategoryType type;
  final String icon;
  final int color;
  const CategoryAdded({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });
  @override
  List<Object?> get props => [name, type, icon, color];
}

class CategoryUpdated extends CategoryEvent {
  final CategoryEntity category;
  const CategoryUpdated(this.category);
  @override
  List<Object?> get props => [category];
}

class CategoryDeleted extends CategoryEvent {
  final String id;
  const CategoryDeleted(this.id);
  @override
  List<Object?> get props => [id];
}
