import '../../core/constants/hive_constants.dart';
import 'hive_service.dart';

class SessionService {
  SessionService({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService.instance;

  final HiveService _hiveService;

  String? get currentEmail {
    final email = _hiveService.appBox.get(HiveConstants.currentEmailKey);
    return email is String ? email : null;
  }

  Future<void> saveEmail(String email) async {
    await _hiveService.appBox.put(
      HiveConstants.currentEmailKey,
      email.trim().toLowerCase(),
    );
  }

  Future<void> clearSession() async {
    await _hiveService.appBox.delete(HiveConstants.currentEmailKey);
  }

  bool get isLoggedIn => currentEmail != null && currentEmail!.isNotEmpty;
}
