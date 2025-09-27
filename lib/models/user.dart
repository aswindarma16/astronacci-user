import 'package:flutter/material.dart';

@immutable
class User {
  final String userName;
  final String? profilePictureFilePath;

  const User({
    required this.userName,
    required this.profilePictureFilePath
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'profilePictureFilePath': profilePictureFilePath
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userName: json['userName'] ?? "",
      profilePictureFilePath: json['profilePictureFilePath'],
    );
  }
}
