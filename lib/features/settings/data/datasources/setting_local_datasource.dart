import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class SettingsLocalDataSource {
  Future<PackageInfo> getPackageInfo();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  const SettingsLocalDataSourceImpl();

  @override
  Future<PackageInfo> getPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (_) {
      throw const CacheException('Could not read app info.');
    }
  }
}
