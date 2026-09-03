import 'package:equatable/equatable.dart';

class AppInfoEntity extends Equatable {
  final String appName;
  final String version;
  final String buildNumber;

  const AppInfoEntity({
    required this.appName,
    required this.version,
    required this.buildNumber,
  });

  @override
  List<Object?> get props => [appName, version, buildNumber];
}
