import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/settings/domain/entities/app_info_entity.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_app_info_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsAppInfoRequested extends SettingsEvent {
  const SettingsAppInfoRequested();
}

// --- State ---
enum SettingsStatusUi { initial, loading, success, failure }

class SettingsState extends Equatable {
  final SettingsStatusUi status;
  final AppInfoEntity? appInfo;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatusUi.initial,
    this.appInfo,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatusUi? status,
    AppInfoEntity? appInfo,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      appInfo: appInfo ?? this.appInfo,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, appInfo, errorMessage];
}

// --- Bloc ---
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetAppInfoUseCase getAppInfoUseCase;

  SettingsBloc({required this.getAppInfoUseCase})
    : super(const SettingsState()) {
    on<SettingsAppInfoRequested>(_onAppInfoRequested);
  }

  Future<void> _onAppInfoRequested(
    SettingsAppInfoRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatusUi.loading));
    final result = await getAppInfoUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SettingsStatusUi.failure,
          errorMessage: failure.message,
        ),
      ),
      (info) => emit(
        state.copyWith(
          status: SettingsStatusUi.success,
          appInfo: info,
          errorMessage: null,
        ),
      ),
    );
  }
}
