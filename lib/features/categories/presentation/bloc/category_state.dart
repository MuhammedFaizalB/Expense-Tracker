part of 'category_bloc.dart';

enum CategoryStatusUi { initial, loading, success, failure }

class CategoryState extends Equatable {
  final CategoryStatusUi status;
  final List<CategoryEntity> categories;
  final String? errorMessage;

  const CategoryState({
    this.status = CategoryStatusUi.initial,
    this.categories = const [],
    this.errorMessage,
  });

  List<CategoryEntity> get income =>
      categories.where((c) => c.type == CategoryType.income).toList();
  List<CategoryEntity> get expense =>
      categories.where((c) => c.type == CategoryType.expense).toList();

  CategoryState copyWith({
    CategoryStatusUi? status,
    List<CategoryEntity>? categories,
    String? errorMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, errorMessage];
}
