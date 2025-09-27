import 'dart:io';
import 'package:flutter/material.dart';
import 'package:user_list/models/user.dart';
import '../databases/user_database.dart';
import '../globals.dart';
import 'user_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<List<User>> _users = ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ScrollController _scrollController = ScrollController();

  int _offset = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMoreUsers();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading.value && _hasMore) {
        _loadMoreUsers();
      }
    });
  }

  Future<void> _loadMoreUsers() async {
    _isLoading.value = true;

    final newUsers = await UserDatabase.loadUsersPaged(
      offset: _offset,
    );

    if (newUsers.length < limitDataPerLoad) _hasMore = false;

    _users.value = [..._users.value, ...newUsers];
    _offset += newUsers.length;

    _isLoading.value = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _users.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset("assets/logo/astronacci_logo.png", height: 32),
            const SizedBox(width: 8),
            const Text(
              "Astronacci",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder<List<User>>(
        valueListenable: _users,
        builder: (context, users, _) {
          if (users.isEmpty && !_isLoading.value) {
            return const Center(child: Text("No users yet"));
          }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailPage(userDetail: user),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: ListTile(
                            leading: user.profilePictureFilePath == null
                                ? CircleAvatar(
                                    backgroundColor: getBackgroundColor(user.userName),
                                    child: Text(
                                      user.userName.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : ClipOval(
                                    child: Image.file(
                                      File(user.profilePictureFilePath!),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                            title: Text(
                              toTitleCase(user.userName),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, loading, _) {
                  return loading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
