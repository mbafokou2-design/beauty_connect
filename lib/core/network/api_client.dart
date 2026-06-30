import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ApiClient {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  static Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // GET
  static Future<http.Response> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
    return await http.get(uri, headers: headers);
  }

  // POST
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
    return await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // PUT
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
    return await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // DELETE
  static Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
    return await http.delete(uri, headers: headers);
  }

  // POST with image (multipart)
static Future<http.Response> postWithImage(
    String endpoint,
    Map<String, String> fields,
    String filePath,
    String fileField,
  ) async {
    final token = await _getToken();
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    final mimeTypeData = lookupMimeType(filePath)?.split('/');
    request.files.add(
      await http.MultipartFile.fromPath(
        fileField,
        filePath,
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}