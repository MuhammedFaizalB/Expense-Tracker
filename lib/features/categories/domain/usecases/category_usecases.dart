import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';

class GetCategoriesParams extends Equatable {
  final CategoryType? type;
  const GetCategoriesParams({this.type});
  @override
  List<Object?> get props => [type];
}

class GetCategoriesUseCase
    implements UseCase<List<CategoryEntity>, GetCategoriesParams> {
  final CategoryRepository repository;
  const GetCategoriesUseCase(this.repository);
  @override
  Future<Either<Failure, List<CategoryEntity>>> call(
    GetCategoriesParams params,
  ) => repository.getCategories(type: params.type);
}

class AddCategoryUseCase implements UseCase<CategoryEntity, CategoryEntity> {
  final CategoryRepository repository;
  const AddCategoryUseCase(this.repository);
  @override
  Future<Either<Failure, CategoryEntity>> call(CategoryEntity params) {
    if (params.name.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Category name cannot be empty.')),
      );
    }
    return repository.createCategory(params);
  }
}

class UpdateCategoryUseCase implements UseCase<CategoryEntity, CategoryEntity> {
  final CategoryRepository repository;
  const UpdateCategoryUseCase(this.repository);
  @override
  Future<Either<Failure, CategoryEntity>> call(CategoryEntity params) =>
      repository.updateCategory(params);
}

class DeleteCategoryUseCase implements UseCase<void, String> {
  final CategoryRepository repository;
  const DeleteCategoryUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteCategory(id);
}
