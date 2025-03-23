import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';


class ApiService {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<double> predictPrice(Map<String, dynamic> laptopData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(laptopData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Predicted Price'].toDouble();
    } else {
      throw Exception('Failed to predict price: ${response.body}');
    }
  }
}