
import 'dart:convert';

class User {
  String? username;
  String? email;
  String? password;

  User({
    this.username,
    this.email,
    this.password,
  });

  @override
  String toString() => 'User(username:$username, email: $email, password: $password)';

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      email: map['email'],
      password: map['password'],
    );
  }
  String toJson() => json.encode(toMap());
  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.username == username &&
        other.email == email &&
        other.password == password;
  }
  @override
  int get hashCode => Object.hash(username, email, password);

}

