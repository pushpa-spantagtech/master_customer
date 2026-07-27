import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';
import 'package:ride_sharing_user_app/features/splash/domain/services/config_service_interface.dart';

class ConfigController extends GetxController implements GetxService {
  final ConfigServiceInterface configServiceInterface;

  ConfigController({required this.configServiceInterface});

  ConfigModel? _config;

  ConfigModel? get config => _config;

  bool loading = false;
  Future<bool>? _configRequest;

  Future<bool> getConfigData({
    bool reload = false,
    bool showError = true,
  }) {
    final Future<bool>? activeRequest = _configRequest;
    if (activeRequest != null) {
      return activeRequest;
    }

    final Future<bool> request = _loadConfigData(
      reload: reload,
      showError: showError,
    );
    _configRequest = request;
    return request;
  }

  Future<bool> _loadConfigData({
    required bool reload,
    required bool showError,
  }) async {
    loading = true;
    if (reload) update();

    try {
      final Response response = await configServiceInterface.getConfigData();

      if (response.statusCode == 200) {
        _config = ConfigModel.fromJson(response.body);
        return true;
      }

      if (showError) {
        ApiChecker.checkApi(response);
      }
      return false;
    } catch (error) {
      return false;
    } finally {
      loading = false;
      _configRequest = null;
      update();
    }
  }

  Future<bool> initSharedData() {
    return configServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() {
    return configServiceInterface.removeSharedData();
  }

  bool showIntro() {
    return configServiceInterface.showIntro()!;
  }

  void disableIntro() {
    configServiceInterface.disableIntro();
  }

  String? _pusherConnectionStatus;

  String? get pusherConnectionStatus => _pusherConnectionStatus;

  void setPusherStatus(String? connection) {
    _pusherConnectionStatus = connection;
  }

  bool haveOngoingRides() {
    return configServiceInterface.haveOngoingRides();
  }

  void saveOngoingRides(bool value) {
    configServiceInterface.saveOngoingRides(value);
  }
}
