import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    CategoryType? type,
  });
  Future<Either<Failure, CategoryEntity>> createCategory(
    CategoryEntity category,
  );
  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  );
  Future<Either<Failure, void>> deleteCategory(String id);
  Future<Either<Failure, void>> reorderCategories(List<String> orderedIds);
}
