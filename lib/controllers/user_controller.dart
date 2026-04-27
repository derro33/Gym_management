import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  final GetStorage _box = GetStorage();

  void saveUser(Map<String, dynamic> user) {
    _box.write('user', user);
  }
  Map<String, dynamic> get user {
    final data = _box.read('user');
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }
  int get userId => int.tryParse(user['id']?.toString() ?? '0') ?? 0;
  String get fullName => user['full_name']?.toString() ?? '';
  String get email => user['email']?.toString() ?? '';
  String get role => user['role']?.toString() ?? 'member';

  void clearUser() {
    _box.remove('user');
  }
}
