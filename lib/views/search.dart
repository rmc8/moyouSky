import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moyousky/models/user_list.dart';
import 'package:moyousky/services/bluesky_api_service.dart';
import 'package:moyousky/views/timeline.dart';
import 'package:moyousky/utils/constants.dart' as cons;
import 'package:moyousky/animation/fade_route.dart';
import 'package:moyousky/widgets/drawer/main_drawer.dart';
import 'package:moyousky/widgets/drawer_button/main_drawer_btn.dart';
import 'package:moyousky/widgets/post/post.dart';
import 'package:moyousky/models/post.dart';
import 'package:moyousky/widgets/navigation/bottom_navi.dart';

String trimLeftHash(String input) {
  return input.replaceFirst(RegExp(r'^#+'), '');
}

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  SearchScreen({this.initialQuery});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _controller;
  List<Actor> _searchResults = [];
  final BlueskyApiService apiService = BlueskyApiService();
  Timer? _debounce;
  List<Post> _postResults = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);

    if (widget.initialQuery != null) {
      _onSearchSubmitted(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      _performSearch(text);
    });
  }

  void _onSearchSubmitted(String text) {
    _performPostSearch(text);
  }

  void _performPostSearch(String query) async {
    if (trimLeftHash(query).isEmpty) return;

    try {
      final response = await apiService.searchForPost(trimLeftHash(query));
      if (response.containsKey('data')) {
        setState(() {
          _postResults = getPostWidgets(response['data']);
        });
      }
    } catch (e) {
      print("Error performing post search: $e");
    }
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      final response = await apiService.searchForUsers(query, limit: 16);
      if (response.containsKey('actors')) {
        List<dynamic> actors = response['actors'];
        setState(() {
          _searchResults = actors.map((actor) => Actor.fromMap(actor)).toList();
        });
      }
    } catch (e) {
      print("Error performing search: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: UserAvatar(),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          title: TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            decoration: const InputDecoration(
              hintText: 'キーワードを入力...',
              hintStyle: TextStyle(fontFamily: cons.DEFAULT_FONT),
            ),
          ),
        ),
        drawer: const MainDrawer(),
        body: _postResults.isNotEmpty
            ? ListView.builder(
                itemCount: _postResults.length,
                itemBuilder: (context, index) {
                  return _postResults[index];
                },
              )
            : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final actor = _searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          actor.avatarUrl != null && actor.avatarUrl.isNotEmpty
                              ? NetworkImage(actor.avatarUrl)
                              : null,
                      child: actor.avatarUrl == null || actor.avatarUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(actor.displayName,
                        style: const TextStyle(
                          fontFamily: cons.DEFAULT_FONT,
                        )),
                    subtitle: Text(actor.handle,
                        style: const TextStyle(
                          fontFamily: cons.DEFAULT_FONT,
                        )),
                    onTap: () {
                      // ユーザープロフィールへの遷移やprintなどのロジックをここに追加
                      print('Selected user handle: ${actor.handle}');
                    },
                  );
                },
              ),
        bottomNavigationBar: BskyBottomNavigationBar(
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).push(FadeRoute(page: Timeline()));
            }
            // 他のindexの処理を追加することができます
          },
        ));
  }
}
