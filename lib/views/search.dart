import 'dart:async';

import 'package:flutter/material.dart';

import 'package:moyousky/views/timeline.dart';
import 'package:moyousky/utils/user_list.dart';
import 'package:moyousky/utils/post_utils.dart';
import 'package:moyousky/utils/fade_route.dart';
import 'package:moyousky/widgets/post/post.dart';
import 'package:moyousky/views/user_profile.dart';
import 'package:moyousky/services/search_service.dart';
import 'package:moyousky/utils/constants.dart' as cons;
import 'package:moyousky/widgets/drawer/main_drawer.dart';
import 'package:moyousky/widgets/navigation/bottom_navi.dart';
import 'package:moyousky/widgets/drawer_button/main_drawer_btn.dart';

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
  final apiService = SearchServiceBeta();
  Timer? _debounce;
  List<Post> _postResults = [];
  bool isLoading = false;

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
    _debounce = Timer(const Duration(milliseconds: 90), () {
      _performSearch(text);
    });
  }

  void _onSearchSubmitted(String text) {
    _performPostSearch(text);
  }

  void _performPostSearch(String query) async {
    if (trimLeftHash(query).isEmpty) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.searchForPost(trimLeftHash(query));
      if (response.containsKey('data')) {
        setState(() {
          _postResults = getPostWidgets(response['data']);
        });
      }
    } catch (e) {
      print("Error performing post search: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (context) => IconButton(
          icon: UserAvatar(),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
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
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_postResults.isNotEmpty) {
      return ListView.builder(
        itemCount: _postResults.length,
        itemBuilder: (context, index) => _postResults[index],
      );
    }

    return ListView.builder(
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
              style: const TextStyle(fontFamily: cons.DEFAULT_FONT)),
          subtitle: Text(actor.handle,
              style: const TextStyle(fontFamily: cons.DEFAULT_FONT)),
          onTap: () {
            Navigator.of(context).push(
                FadeRoute(page: UserProfile(did: actor.handle)));
          },
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BskyBottomNavigationBar(
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).push(FadeRoute(page: Timeline()));
        }
        // 他のindexの処理を追加することができます
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const MainDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
