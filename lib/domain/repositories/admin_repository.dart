import '../../core/services/http_service.dart';
import '../models/user.dart';
import '../models/area.dart';

class AdminRepository {
  final DioHttpService http;

  AdminRepository(this.http);

  // --- Users ---
  Future<List<User>> getUsers({Map<String, dynamic>? query}) async {
    final res = await http.get('/users', queryParameters: query);
    final data = res.data;
    if (data is List) {
      return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<User> getUserById(num id) async {
    final res = await http.get('/users/\$id'.replaceAll('\$id', id.toString()));
    final data = res.data;
    if (data is Map<String, dynamic>) return User.fromJson(data);
    throw Exception('Invalid user response');
  }

  Future<User> createUser(Map<String, dynamic> dto) async {
    final res = await http.post('/users', data: dto);
    final data = res.data;
    if (data is Map<String, dynamic>) return User.fromJson(data);
    if (data is Map && data['data'] is Map<String, dynamic>) return User.fromJson(data['data']);
    throw Exception('Invalid create user response');
  }

  Future<User> updateUser(num id, Map<String, dynamic> dto) async {
    final res = await http.patch('/users/\$id'.replaceAll('\$id', id.toString()), data: dto);
    final data = res.data;
    if (data is Map<String, dynamic>) return User.fromJson(data);
    if (data is Map && data['data'] is Map<String, dynamic>) return User.fromJson(data['data']);
    throw Exception('Invalid update user response');
  }

  Future<void> deleteUser(num id) async {
    await http.delete('/users/\$id'.replaceAll('\$id', id.toString()));
  }

  // --- Areas ---
  Future<List<Area>> getAreas({Map<String, dynamic>? query}) async {
    final res = await http.get('/areas', queryParameters: query);
    final data = res.data;
    if (data is List) {
      return data.map((e) => Area.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => Area.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Area> getAreaById(num id) async {
    final res = await http.get('/areas/\$id'.replaceAll('\$id', id.toString()));
    final data = res.data;
    if (data is Map<String, dynamic>) return Area.fromJson(data);
    throw Exception('Invalid area response');
  }

  Future<Area> createArea(Map<String, dynamic> dto) async {
    final res = await http.post('/areas', data: dto);
    final data = res.data;
    if (data is Map<String, dynamic>) return Area.fromJson(data);
    if (data is Map && data['data'] is Map<String, dynamic>) return Area.fromJson(data['data']);
    throw Exception('Invalid create area response');
  }

  Future<Area> updateArea(num id, Map<String, dynamic> dto) async {
    final res = await http.patch('/areas/\$id'.replaceAll('\$id', id.toString()), data: dto);
    final data = res.data;
    if (data is Map<String, dynamic>) return Area.fromJson(data);
    if (data is Map && data['data'] is Map<String, dynamic>) return Area.fromJson(data['data']);
    throw Exception('Invalid update area response');
  }

  Future<void> deleteArea(num id) async {
    await http.delete('/areas/\$id'.replaceAll('\$id', id.toString()));
  }
}
