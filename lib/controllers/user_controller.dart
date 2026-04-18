import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  // GetStorage is the local storage box — like a mini database saved on the device
  // It remembers the logged-in user even if the app is closed and reopened
  final GetStorage _box = GetStorage();

  // Save user data to device storage after login
  void saveUser(Map<String, dynamic> user) {
    _box.write('user', user);
  }

  // Read user data from device storage
  Map<String, dynamic> get user {
    final data = _box.read('user');
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }

  // Quick access helpers — use these instead of user['id'] everywhere
  int get userId => int.tryParse(user['id']?.toString() ?? '0') ?? 0;
  String get fullName => user['full_name']?.toString() ?? '';
  String get email => user['email']?.toString() ?? '';
  String get role => user['role']?.toString() ?? 'member';

  // Call this on logout to wipe the saved session
  void clearUser() {
    _box.remove('user');
  }
}
