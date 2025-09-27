import 'dart:io';

import 'package:flutter/material.dart';
import '../globals.dart';
import '../models/user.dart';

class UserDetailPage extends StatefulWidget {
  final User userDetail;

  const UserDetailPage({super.key, required this.userDetail});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              widget.userDetail.profilePictureFilePath == null
                  ? CircleAvatar(
                      radius: 150,
                      backgroundColor: getBackgroundColor(
                        widget.userDetail.userName,
                      ),
                      child: Text(
                        widget.userDetail.userName
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 40,
                        ),
                      ),
                    )
                  : ClipOval(
                      child: Image.file(
                        File(widget.userDetail.profilePictureFilePath!),
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
              const SizedBox(height: 30),
              Text(
                widget.userDetail.userName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
