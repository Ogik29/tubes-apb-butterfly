import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/butterfly_model.dart';
import '../models/scan_result_model.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';

    // IP laptop untuk koneksi dari device fisik eksternal
    const String laptopIp = '192.168.1.234';

    try {
      return 'http://$laptopIp:8000';
      // Catatan: Jika kembali menggunakan Android Emulator, gunakan 'http://10.0.2.2:8000'
    } catch (_) {}
    return 'http://localhost:8000';
  }

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- AUTHENTICATION ---

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: await _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['data']['access_token'];
      final userJson = data['data']['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', userJson['role']);
      await prefs.setString('user_name', userJson['name']);

      return {
        'user': UserModel.fromJson(userJson),
        'token': token,
      };
    } else {
      throw Exception(data['message'] ?? 'Email atau password salah.');
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 && data['success'] == true) {
      final token = data['data']['access_token'];
      final userJson = data['data']['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', userJson['role']);
      await prefs.setString('user_name', userJson['name']);

      return {
        'user': UserModel.fromJson(userJson),
        'token': token,
      };
    } else {
      // Ambil detail error jika ada error validasi
      String errorMessage = data['message'] ?? 'Gagal melakukan registrasi.';
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        errorMessage =
            errors.values.map((e) => (e as List).join(', ')).join('\n');
      }
      throw Exception(errorMessage);
    }
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: await _headers(),
      );
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
  }

  static Future<UserModel?> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return UserModel.fromJson(data['data']);
        }
      }
    } catch (e) {
      debugPrint('Error getMe: $e');
    }
    return null;
  }

  // --- BUTTERFLIES ---

  static Future<List<ButterflyModel>> getButterflies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/butterflies'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? [];
      return list.map((item) => ButterflyModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data kupu-kupu dari server.');
    }
  }

  static Future<ButterflyModel> getButterflyDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/butterflies/$id'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ButterflyModel.fromJson(data['data']);
    } else {
      throw Exception('Gagal memuat detail kupu-kupu.');
    }
  }

  // --- SCAN & COLLECTION ---

  static Future<ScanResultModel> scanImage(XFile imageFile) async {
    final uri = Uri.parse('$baseUrl/api/scan');
    final request = http.MultipartRequest('POST', uri);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Lampirkan file gambar sesuai platform (Web vs Mobile)
    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
      ));
    } else {
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return ScanResultModel.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Gagal melakukan analisis gambar.');
    }
  }

  static Future<ScanResultModel> saveScan(int scanResultId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/scan/$scanResultId/save'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return ScanResultModel.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Gagal menyimpan hasil scan.');
    }
  }

  static Future<List<ButterflyModel>> getCollection() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/collection'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? [];
      return list.map((item) => ButterflyModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat koleksi pengguna.');
    }
  }

  // --- HISTORY ---

  static Future<List<ScanResultModel>> getHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/history'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? [];
      return list.map((item) => ScanResultModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat riwayat scan.');
    }
  }

  static Future<void> deleteHistory(int scanResultId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/history/$scanResultId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal menghapus riwayat.');
    }
  }

  // --- DASHBOARD STATS ---

  static Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard/stats'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Gagal memuat data statistik dashboard.');
    }
  }

  static Future<Map<String, dynamic>> getAdminStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard/admin-stats'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Gagal memuat data statistik admin.');
    }
  }

  // --- ADMIN MASTER DATA CRUD ---

  static Future<ButterflyModel> addButterfly(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/butterflies'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 ||
        (response.statusCode == 200 && data['success'] == true)) {
      return ButterflyModel.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Gagal menambahkan spesies.');
    }
  }

  static Future<ButterflyModel> updateButterfly(
      int id, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/butterflies/$id'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return ButterflyModel.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Gagal memperbarui spesies.');
    }
  }

  static Future<void> deleteButterfly(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/butterflies/$id'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(
          data['message'] ?? 'Gagal menghapus spesies dari database.');
    }
  }
}
