import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/domain/usecases/category_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(const CategoryState()) {
    on<CategoryLoadRequested>(_onLoad);
    on<CategoryAdded>(_onAdded);
    on<CategoryUpdated>(_onUpdated);
    on<CategoryDeleted>(_onDeleted);
  }

  Future<void> _onLoad(
    CategoryLoadRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatusUi.loading));
    final result = await getCategoriesUseCase(const GetCategoriesParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          status: CategoryStatusUi.failure,
          errorMessage: f.message,
        ),
      ),
      (list) => emit(
        state.copyWith(
          status: CategoryStatusUi.success,
          categories: list,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onAdded(
    CategoryAdded event,
    Emitter<CategoryState> emit,
  ) async {
    final now = DateTime.now();
    final entity = CategoryEntity(
      id: const Uuid().v4(),
      name: event.name,
      type: event.type,
      icon: event.icon,
      color: event.color,
      isDefault: false,
      sortOrder: state.categories.length,
      createdAt: now,
      updatedAt: now,
    );
    final result = await addCategoryUseCase(entity);
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (created) => emit(
        state.copyWith(
          categories: [...state.categories, created],
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onUpdated(
    CategoryUpdated event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await updateCategoryUseCase(event.category);
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (updated) => emit(
        state.copyWith(
          categories: state.categories
              .map((c) => c.id == updated.id ? updated : c)
              .toList(),
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onDeleted(
    CategoryDeleted event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await deleteCategoryUseCase(event.id);
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (_) => emit(
        state.copyWith(
          categories: state.categories.where((c) => c.id != event.id).toList(),
          errorMessage: null,
        ),
      ),
    );
  }
}
