import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/settings/domain/entities/app_info_entity.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

class GetAppInfoUseCase implements UseCase<AppInfoEntity, NoParams> {
  final SettingsRepository repository;
  const GetAppInfoUseCase(this.repository);

  @override
  Future<Either<Failure, AppInfoEntity>> call(NoParams params) =>
      repository.getAppInfo();
}
