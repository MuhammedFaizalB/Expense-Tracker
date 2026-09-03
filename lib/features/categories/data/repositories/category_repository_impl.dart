import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:expense_tracker/features/categories/data/models/category_model.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remote;
  final NetworkInfo networkInfo;
  const CategoryRepositoryImpl(this.remote, this.networkInfo);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await action());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    CategoryType? type,
  }) => _guard(() => remote.getCategories(type: type));

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(
    CategoryEntity category,
  ) => _guard(() => remote.createCategory(_toModel(category)));

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  ) => _guard(() => remote.updateCategory(_toModel(category)));

  @override
  Future<Either<Failure, void>> deleteCategory(String id) =>
      _guard(() => remote.deleteCategory(id));

  @override
  Future<Either<Failure, void>> reorderCategories(List<String> orderedIds) =>
      _guard(() => remote.reorderCategories(orderedIds));

  CategoryModel _toModel(CategoryEntity e) => CategoryModel(
    id: e.id,
    userId: e.userId,
    name: e.name,
    type: e.type,
    icon: e.icon,
    color: e.color,
    isDefault: e.isDefault,
    sortOrder: e.sortOrder,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );
}
