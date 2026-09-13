import '../models/profile.dart';
import 'api_client.dart';

class ProfileService {
  final _client = ApiClient();

  Future<Profile> getProfile() async {
    final data = await _client.get('/api/profile') as Map<String, dynamic>;
    return Profile.fromJson(data);
  }

  Future<Profile> updateProfile({required String fullName, String? phone}) async {
    final data = await _client.put('/api/profile', {
      'fullName': fullName,
      'phone': phone,
    }) as Map<String, dynamic>;
    return Profile.fromJson(data);
  }
}
