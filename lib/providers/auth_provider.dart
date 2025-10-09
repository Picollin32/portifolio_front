import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = true;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isAdmin => _user?.role == UserRole.admin;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final savedToken = prefs.getString('token');

      if (userJson != null && savedToken != null) {
        _user = User.fromJson(jsonDecode(userJson));
        _token = savedToken;
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      print('🔑 AuthProvider.login() chamado');
      print('📧 Email: $email');

      // Tenta fazer login via API
      final result = await ApiService.login(email: email, password: password);

      print('📦 Resultado da API: $result');

      if (result['success'] == true) {
        final token = result['data']['access_token'] as String;
        print('🎫 Token recebido: ${token.substring(0, 20)}...');

        // Decodifica o token JWT para obter as informações do usuário
        final payload = ApiService.decodeJwtPayload(token);
        print('📝 Payload decodificado: $payload');

        if (payload != null) {
          final userEmail = payload['sub'] as String;
          final userRole = payload['role'] as String;

          print('👤 Usuário: $userEmail, Role: $userRole');

          // Cria o objeto do usuário
          final userData = User(
            id: userEmail, // Usando email como ID temporariamente
            email: userEmail,
            name: userRole == 'admin' ? 'Administrador' : 'Usuário',
            role: userRole == 'admin' ? UserRole.admin : UserRole.user,
          );

          _user = userData;
          _token = token;

          // Salva no SharedPreferences
          await _saveUser(userData);
          await _saveToken(token);

          print('✅ Login bem-sucedido!');
          notifyListeners();
          return true;
        }
      }

      print('❌ Login falhou');
      return false;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      print('🐛 Stack trace:');
      print(e);

      // Fallback para login local (admin apenas) se API não estiver disponível
      if (email == 'admin@portfolio.com' && password == 'admin123') {
        print('🔄 Usando fallback local para admin');
        final userData = User(id: 'admin', email: email, name: 'Administrador', role: UserRole.admin);
        _user = userData;
        _token = 'local-admin-token';
        await _saveUser(userData);
        await _saveToken('local-admin-token');
        notifyListeners();
        return true;
      }

      return false;
    }
  }

  Future<Map<String, dynamic>> register(RegisterData registerData) async {
    try {
      print('📝 AuthProvider.register() chamado');
      print('📧 Email: ${registerData.email}');

      // Tenta fazer registro via API
      final result = await ApiService.register(
        email: registerData.email,
        password: registerData.password,
        firstName: registerData.firstName,
        lastName: registerData.lastName,
        photo: registerData.photo,
      );

      print('📦 Resultado da API: $result');

      if (result['success'] == true) {
        print('✅ Registro bem-sucedido!');
        return {'success': true};
      } else {
        final errorMessage = result['error'] ?? 'Erro ao cadastrar usuário';
        print('❌ Registro falhou: $errorMessage');
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('❌ Erro no registro: $e');

      // Fallback para SharedPreferences (se API não estiver disponível)
      try {
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString('registeredUsers');

        List<dynamic> users = [];
        if (usersJson != null) {
          users = jsonDecode(usersJson);
        }

        // Check if email already exists
        if (users.any((u) => u['email'] == registerData.email)) {
          return {'success': false, 'error': 'Este email já está cadastrado'};
        }

        if (registerData.email == 'admin@portfolio.com') {
          return {'success': false, 'error': 'Este email não pode ser usado'};
        }

        // Create new user
        final newUser = {'id': DateTime.now().millisecondsSinceEpoch.toString(), ...registerData.toJson()};

        users.add(newUser);
        await prefs.setString('registeredUsers', jsonEncode(users));

        print('✅ Registro local bem-sucedido (fallback)');
        return {'success': true};
      } catch (fallbackError) {
        debugPrint('Erro no fallback de registro: $fallbackError');
        return {'success': false, 'error': 'Erro ao cadastrar usuário'};
      }
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateProfile(ProfileUpdateData updates) async {
    if (_user == null) {
      return {'success': false, 'error': 'Usuário não autenticado'};
    }

    try {
      // Admin update
      if (_user!.role == UserRole.admin) {
        _user = _user!.copyWith(photo: updates.photo);
        await _saveUser(_user!);
        notifyListeners();
        return {'success': true};
      }

      // Regular user update
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('registeredUsers');

      if (usersJson != null) {
        List<dynamic> users = jsonDecode(usersJson);
        final userIndex = users.indexWhere((u) => u['id'] == _user!.id);

        if (userIndex == -1) {
          return {'success': false, 'error': 'Usuário não encontrado'};
        }

        final storedUser = users[userIndex];

        // Check current password if changing password
        if (updates.newPassword != null) {
          if (updates.currentPassword == null) {
            return {'success': false, 'error': 'Senha atual é obrigatória'};
          }
          if (storedUser['password'] != updates.currentPassword) {
            return {'success': false, 'error': 'Senha atual incorreta'};
          }
          storedUser['password'] = updates.newPassword;
        }

        // Update photo
        if (updates.photo != null) {
          storedUser['photo'] = updates.photo;
        }

        users[userIndex] = storedUser;
        await prefs.setString('registeredUsers', jsonEncode(users));

        // Update current user session
        _user = _user!.copyWith(photo: storedUser['photo']);
        await _saveUser(_user!);
        notifyListeners();

        return {'success': true};
      }

      return {'success': false, 'error': 'Erro ao atualizar perfil'};
    } catch (e) {
      debugPrint('Update profile error: $e');
      return {'success': false, 'error': 'Erro ao atualizar perfil'};
    }
  }

  Future<List<User>> getAllUsers() async {
    if (_user == null || _user!.role != UserRole.admin || _token == null) {
      return [];
    }

    try {
      print('👥 AuthProvider.getAllUsers() chamado');

      // Tenta buscar usuários via API
      final result = await ApiService.getAllUsers(_token!);

      if (result['success'] == true) {
        final List<dynamic> usersData = result['data'];
        print('✅ ${usersData.length} usuários recebidos da API');

        return usersData.map((userData) {
          // Converte o formato do backend para o formato do modelo
          return User(
            id: userData['id'].toString(),
            email: userData['email'],
            name: userData['full_name'] ?? 'Sem nome',
            firstName: userData['full_name']?.split(' ').first,
            lastName: userData['full_name']?.split(' ').skip(1).join(' '),
            photo: userData['profile_image_url'],
            role: userData['role']['name'] == 'admin' ? UserRole.admin : UserRole.user,
          );
        }).toList();
      }

      print('⚠️ Falha na API, usando fallback local');
    } catch (e) {
      print('❌ Erro ao buscar usuários da API: $e');
    }

    // Fallback para SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('registeredUsers');

      if (usersJson != null) {
        final List<dynamic> users = jsonDecode(usersJson);
        return users
            .map(
              (u) => User(
                id: u['id'],
                email: u['email'],
                name: '${u['firstName']} ${u['lastName']}',
                firstName: u['firstName'],
                lastName: u['lastName'],
                photo: u['photo'],
                role: UserRole.user,
              ),
            )
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Get all users error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> deleteUser(String userId) async {
    if (_user == null || _user!.role != UserRole.admin || _token == null) {
      return {'success': false, 'error': 'Acesso negado'};
    }

    try {
      print('🗑️ AuthProvider.deleteUser() chamado para userId: $userId');

      // Tenta deletar via API
      final userIdInt = int.tryParse(userId);
      if (userIdInt != null) {
        final result = await ApiService.deleteUser(token: _token!, userId: userIdInt);

        if (result['success'] == true) {
          print('✅ Usuário deletado via API');
          return {'success': true};
        }

        print('⚠️ Falha na API: ${result['error']}');
      }
    } catch (e) {
      print('❌ Erro ao deletar via API: $e');
    }

    // Fallback para SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('registeredUsers');

      if (usersJson != null) {
        List<dynamic> users = jsonDecode(usersJson);
        users.removeWhere((u) => u['id'] == userId);
        await prefs.setString('registeredUsers', jsonEncode(users));
        return {'success': true};
      }

      return {'success': false, 'error': 'Usuário não encontrado'};
    } catch (e) {
      debugPrint('Delete user error: $e');
      return {'success': false, 'error': 'Erro ao deletar usuário'};
    }
  }

  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> updates) async {
    if (_user == null || _user!.role != UserRole.admin || _token == null) {
      return {'success': false, 'error': 'Acesso negado'};
    }

    try {
      print('✏️ AuthProvider.updateUser() chamado para userId: $userId');
      print('📝 Updates: $updates');

      // Tenta atualizar via API
      final userIdInt = int.tryParse(userId);
      if (userIdInt != null) {
        // Extrai os campos para o formato da API
        String? fullName;
        if (updates.containsKey('firstName') && updates.containsKey('lastName')) {
          fullName = '${updates['firstName']} ${updates['lastName']}';
        } else if (updates.containsKey('full_name')) {
          fullName = updates['full_name'];
        }

        final result = await ApiService.updateUser(
          token: _token!,
          userId: userIdInt,
          fullName: fullName,
          profileImageUrl: updates['photo'],
          password: updates['password'],
        );

        if (result['success'] == true) {
          print('✅ Usuário atualizado via API');
          return {'success': true};
        }

        print('⚠️ Falha na API: ${result['error']}');
      }
    } catch (e) {
      print('❌ Erro ao atualizar via API: $e');
    }

    // Fallback para SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('registeredUsers');

      if (usersJson != null) {
        List<dynamic> users = jsonDecode(usersJson);
        final userIndex = users.indexWhere((u) => u['id'] == userId);

        if (userIndex == -1) {
          return {'success': false, 'error': 'Usuário não encontrado'};
        }

        users[userIndex] = {...users[userIndex], ...updates};
        await prefs.setString('registeredUsers', jsonEncode(users));
        return {'success': true};
      }

      return {'success': false, 'error': 'Usuário não encontrado'};
    } catch (e) {
      debugPrint('Update user error: $e');
      return {'success': false, 'error': 'Erro ao atualizar usuário'};
    }
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
}
