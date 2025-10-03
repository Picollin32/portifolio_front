class User {
  final String id;
  final String email;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? photo;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.firstName,
    this.lastName,
    this.photo,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'photo': photo,
      'role': role.name,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      photo: json['photo'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? firstName,
    String? lastName,
    String? photo,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photo: photo ?? this.photo,
      role: role ?? this.role,
    );
  }
}

enum UserRole {
  admin,
  user,
}

class RegisterData {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? photo;

  RegisterData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.photo,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'photo': photo,
    };
  }

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      photo: json['photo'] as String?,
    );
  }
}

class ProfileUpdateData {
  final String? currentPassword;
  final String? newPassword;
  final String? photo;

  ProfileUpdateData({
    this.currentPassword,
    this.newPassword,
    this.photo,
  });
}
