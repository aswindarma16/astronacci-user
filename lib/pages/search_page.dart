import 'dart:io';

import 'package:flutter/material.dart';
import '../databases/search_history_database.dart';
import '../databases/user_database.dart';
import '../globals.dart';
import '../models/user.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchKeywordTextController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final ValueNotifier<List<User>> _users = ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<List<String>> _history = ValueNotifier([]);

  final ScrollController _scrollController = ScrollController();

  String _currentKeyword = "";
  int _offset = 0;
  bool _hasMore = true;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();

    _searchKeywordTextController.addListener(() {
      _currentKeyword = _searchKeywordTextController.text;
      _history.value = List.from(_history.value);
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showDropdown = true;
        _history.value = List.from(_history.value);
      } else {
        _showDropdown = false;
        _history.value = List.from(_history.value);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading.value && _hasMore && _currentKeyword.isNotEmpty) {
        _loadMoreUsers();
      }
    });
  }

  @override
  void dispose() {
    _searchKeywordTextController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _users.dispose();
    _isLoading.dispose();
    _history.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await SearchHistoryDatabase.getHistory();
    _history.value = history.take(5).toList();
  }

  Future<void> _startSearch(String keyword) async {
    if (keyword.trim().isEmpty) {
      _offset = 0;
      _hasMore = true;
      _users.value = [];
      return;
    }

    _focusNode.unfocus();
    _showDropdown = false;

    _currentKeyword = keyword;
    _offset = 0;
    _hasMore = true;
    _users.value = [];

    await SearchHistoryDatabase.addKeyword(keyword);
    await _loadHistory();

    _loadMoreUsers();
  }

  Future<void> _loadMoreUsers() async {
    _isLoading.value = true;
    final newUsers = await UserDatabase.searchUsersByUserName(
      keyword: _currentKeyword,
      offset: _offset,
    );

    if (newUsers.length < limitDataPerLoad) _hasMore = false;

    _users.value = [..._users.value, ...newUsers];
    _offset += newUsers.length;
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Material(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                  controller: _searchKeywordTextController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(15),
                    filled: true,
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    hintText: "Search by username...",
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: _startSearch,
                ),
              ),
            ),
            SizedBox(
              height: 15
            ),
            // Dropdown history below search bar
            ValueListenableBuilder<List<String>>(
              valueListenable: _history,
              builder: (context, history, _) {
                if (!_showDropdown) return const SizedBox.shrink();
        
                final filteredHistory = history
                    .where((h) => h
                        .toLowerCase()
                        .contains(_currentKeyword.toLowerCase()))
                    .take(5)
                    .toList();
        
                if (filteredHistory.isEmpty) return const SizedBox.shrink();
        
                return Container(
                  color: Colors.white,
                  child: Column(
                    children: filteredHistory.map((keyword) {
                      return ListTile(
                        title: Text(keyword),
                        leading: const Icon(Icons.history),
                        onTap: () {
                          _searchKeywordTextController.text = keyword;
                          _startSearch(keyword);
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            await SearchHistoryDatabase.deleteKeyword(keyword);
                            _loadHistory();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            Expanded(
              child: ValueListenableBuilder<List<User>>(
                valueListenable: _users,
                builder: (context, users, _) {
                  if (_currentKeyword.isEmpty) {
                    return const Center(
                      child: Text("Type to search usernames..."),
                    );
                  }
        
                  if (users.isEmpty && !_isLoading.value) {
                    return const Center(
                      child: Text("No results found"),
                    );
                  }
        
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return Card(
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
                              );
                            },
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
