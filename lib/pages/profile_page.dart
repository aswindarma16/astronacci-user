import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../blocs/authentication_bloc.dart';
import '../databases/user_database.dart';
import '../globals.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? userData;
  final ValueNotifier<String?> _profilePicturePath = ValueNotifier(null);

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthenticationBloc>().state;

    if (authState is AuthenticationAuthenticated) {
      userData = authState.userData;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 90);

    if (pickedFile != null && userData != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: primaryYellow,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      if (croppedFile != null) {
        _profilePicturePath.value = croppedFile.path;

        await UserDatabase.saveUserProfilePicture(
          userName: userData!.userName,
          profilePictureFilePath: croppedFile.path,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated")),
          );

          context.read<AuthenticationBloc>().add(
            UpdateUserData(
              newProfilePictureFilePath: croppedFile.path
            ),
          );
        }
      }
    }
  }

  Future<void> _removeImage() async {
    if (userData != null) {
      _profilePicturePath.value = null;

      await UserDatabase.saveUserProfilePicture(
        userName: userData!.userName,
        profilePictureFilePath: null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture removed")),
        );

        context.read<AuthenticationBloc>().add(
          UpdateUserData(
            newProfilePictureFilePath: null
          ),
        );
      }
    }
  }

  void _showPictureOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Remove Photo"),
              onTap: () {
                Navigator.pop(context);
                _removeImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _profilePicturePath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthenticationBloc>().add(LogOut());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _showPictureOptions,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    BlocBuilder<AuthenticationBloc, AuthenticationState>(
                      buildWhen: (prev, curr) {
                        return prev.runtimeType != curr.runtimeType;
                      },
                      builder: (context, authenticationState) {
                        if(authenticationState is AuthenticationAuthenticated) {
                          userData = authenticationState.userData;
                          _profilePicturePath.value = userData!.profilePictureFilePath;
                        }
                        
                        return ValueListenableBuilder<String?>(
                          valueListenable: _profilePicturePath,
                          builder: (context, path, _) {
                            return path == null
                                ? userData?.profilePictureFilePath == null
                                      ? CircleAvatar(
                                          radius: 100,
                                          backgroundColor: getBackgroundColor(
                                            userData?.userName ?? "",
                                          ),
                                          child: Text(
                                            userData?.userName
                                                    .substring(0, 1)
                                                    .toUpperCase() ??
                                                "Unknown",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 40
                                            ),
                                          ),
                                        )
                                      : ClipOval(
                                          child: Image.file(
                                            File(userData!.profilePictureFilePath!),
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                : CircleAvatar(
                                    radius: 100,
                                    backgroundImage: FileImage(File(path)),
                                  );
                          },
                        );
                      }
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 60),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                userData?.userName ?? "Unknown",
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
