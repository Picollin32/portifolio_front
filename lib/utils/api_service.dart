import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Configuração da URL base da API
  // Altere para a URL onde seu backend está rodando
  static const String baseUrl = 'http://localhost:8000';
  
  // Headers padrão para requisições
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Headers com autenticação
  static Map<String, String> _authHeaders(String token) => {
        ..._headers,
        'Authorization': 'Bearer $token',
      };

  /// Login do usuário
  /// Retorna um mapa com 'success' (bool) e 'data' ou 'error'
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Tentando login com email: $email');
      print('🌐 URL: $baseUrl/auth/login');
      
      // FastAPI OAuth2PasswordRequestForm espera form-data, não JSON
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': email, // OAuth2 usa 'username' mesmo sendo email
          'password': password,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tempo de conexão esgotado');
        },
      );

      print('📡 Status da resposta: ${response.statusCode}');
      print('📄 Corpo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Login bem-sucedido!');
        return {
          'success': true,
          'data': {
            'access_token': data['access_token'],
            'token_type': data['token_type'],
          },
        };
      } else if (response.statusCode == 401) {
        print('❌ Credenciais inválidas (401)');
        return {
          'success': false,
          'error': 'Email ou senha incorretos',
        };
      } else {
        print('❌ Erro no servidor: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Erro no servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Erro de conexão: $e');
      return {
        'success': false,
        'error': 'Erro de conexão: $e',
      };
    }
  }

  /// Decodifica o JWT token para obter informações do usuário
  /// Nota: Esta é uma decodificação básica sem validação de assinatura
  static Map<String, dynamic>? decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Busca dados do usuário (exemplo de requisição autenticada)
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: _authHeaders(token),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Não autenticado',
        };
      } else {
        return {
          'success': false,
          'error': 'Erro ao buscar perfil: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: $e',
      };
    }
  }

  /// Registro de novo usuário (se disponível no backend)
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? photo,
  }) async {
    try {
      print('📝 Tentando registrar usuário: $email');
      print('🌐 URL: $baseUrl/auth/register');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          if (photo != null) 'photo': photo,
        }),
      ).timeout(
        const Duration(seconds: 10),
      );

      print('📡 Status da resposta: ${response.statusCode}');
      print('📄 Corpo da resposta: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Registro bem-sucedido!');
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final errorDetail = data['detail'] ?? 'Dados inválidos ou usuário já existe';
        print('❌ Erro 400: $errorDetail');
        return {
          'success': false,
          'error': errorDetail,
        };
      } else {
        print('❌ Erro no servidor: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Erro no servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Erro de conexão no registro: $e');
      return {
        'success': false,
        'error': 'Erro de conexão: $e',
      };
    }
  }

  /// Verifica se a API está online
  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/docs'),
      ).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
