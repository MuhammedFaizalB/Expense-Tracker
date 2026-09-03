import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/settings/data/datasources/setting_local_datasource.dart';
import 'package:expense_tracker/features/settings/domain/entities/app_info_entity.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  const SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, AppInfoEntity>> getAppInfo() async {
    try {
      final info = await localDataSource.getPackageInfo();
      return Right(
        AppInfoEntity(
          appName: info.appName,
          version: info.version,
          buildNumber: info.buildNumber,
        ),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
