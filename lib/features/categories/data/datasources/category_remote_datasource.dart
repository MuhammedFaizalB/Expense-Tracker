import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/categories/data/models/category_model.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({CategoryType? type});
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<void> reorderCategories(List<String> orderedIds);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final SupabaseClient client;
  const CategoryRemoteDataSourceImpl(this.client);

  @override
  Future<List<CategoryModel>> getCategories({CategoryType? type}) async {
    try {
      var query = client.from(SupabaseTables.categories).select();
      if (type != null) {
        query = query.eq(
          'type',
          type == CategoryType.income ? 'income' : 'expense',
        );
      }
      final rows = await query.order('sort_order', ascending: true);
      return (rows as List)
          .map((r) => CategoryModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const ServerException('Could not load categories.');
    }
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final row = await client
          .from(SupabaseTables.categories)
          .insert(category.toInsertJson())
          .select()
          .single();
      return CategoryModel.fromJson(row);
    } catch (_) {
      throw const ServerException('Could not create the category.');
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final row = await client
          .from(SupabaseTables.categories)
          .update(category.toInsertJson())
          .eq('id', category.id)
          .select()
          .single();
      return CategoryModel.fromJson(row);
    } catch (_) {
      throw const ServerException('Could not update the category.');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await client.from(SupabaseTables.categories).delete().eq('id', id);
    } on PostgrestException catch (e) {
      // Foreign key violation from transactions still referencing this
      // category (ON DELETE RESTRICT) — surface a clear message instead of
      // the raw Postgres error.
      if (e.code == '23503') {
        throw const ServerException(
          'This category is used by existing transactions and cannot be deleted.',
        );
      }
      throw const ServerException('Could not delete the category.');
    } catch (_) {
      throw const ServerException('Could not delete the category.');
    }
  }

  @override
  Future<void> reorderCategories(List<String> orderedIds) async {
    try {
      for (var i = 0; i < orderedIds.length; i++) {
        await client
            .from(SupabaseTables.categories)
            .update({'sort_order': i})
            .eq('id', orderedIds[i]);
      }
    } catch (_) {
      throw const ServerException('Could not save the new order.');
    }
  }
}
