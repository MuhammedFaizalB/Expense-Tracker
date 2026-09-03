import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/settings/domain/entities/app_info_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, AppInfoEntity>> getAppInfo();
}
