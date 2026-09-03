import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';

class GetLendingsParams extends Equatable {
  final LendingType? type;
  final LendingStatus? status;
  const GetLendingsParams({this.type, this.status});
  @override
  List<Object?> get props => [type, status];
}

class GetLendingsUseCase
    implements UseCase<List<LendingEntity>, GetLendingsParams> {
  final LendingRepository repository;
  const GetLendingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<LendingEntity>>> call(GetLendingsParams params) {
    return repository.getLendings(type: params.type, status: params.status);
  }
}
