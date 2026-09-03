import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase
    implements UseCase<DashboardSummary, NoParams> {
  final DashboardRepository repository;
  const GetDashboardSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardSummary>> call(NoParams params) =>
      repository.getDashboardSummary();
}
