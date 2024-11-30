import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repo/features/repo/bloc/repo_event.dart';
import 'package:github_repo/features/repo/bloc/repo_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/repo.dart';

class RepoBloc extends Bloc<RepoEvent, RepoState> {
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  final scrollController = ScrollController();
  final searchController = TextEditingController();
  int currentPage = 1;
  bool isFetching = false;
  String currentSearchText = '';

  RepoBloc() : super(const RepoLoading([])) {
    on<FetchReposEvent>(_fetchRepos);
    on<OpenRepoUrlEvent>(_openRepoUrl);
    on<SearchReposEvent>(_searchRepos);

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        add(FetchReposEvent(searchText: currentSearchText));
      }
    });
  }

  Future<void> _fetchRepos(FetchReposEvent event, Emitter<RepoState> emit) async {
    if (isFetching) return;
    isFetching = true;
    currentSearchText = event.searchText ?? '';

    try {
      if (state.repos.isNotEmpty) {
        emit(RepoLoadingMore(state.repos));
      }

      final token = await _getToken();
      String apiUrl;

      if (currentSearchText.isNotEmpty) {
        // Search only in user's repositories
        apiUrl = 'https://api.github.com/search/repositories?q=$currentSearchText+page=$currentPage&per_page=10';
      } else {
        // Fetch all user repositories
        apiUrl = 'https://api.github.com/user/repos?page=$currentPage&per_page=10';
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'token $token'},
      );

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);
        List<Repo> newRepos = [];

        // Handle different response structures
        if (decodedBody is Map<String, dynamic>) {
          // Search results have a different structure
          final List<dynamic> items = decodedBody['items'] ?? [];
          newRepos = items.map((repoJson) => Repo.fromJson(repoJson)).toList();
        } else if (decodedBody is List<dynamic>) {
          // Regular repo listing
          newRepos = decodedBody.map((repoJson) => Repo.fromJson(repoJson)).toList();
        }

        final updatedRepos = List<Repo>.from(state.repos)..addAll(newRepos);
        await _saveReposToCache(updatedRepos);

        emit(RepoLoaded(updatedRepos));
        currentPage++;
      } else {
        emit(RepoError(state.repos, "Error loading repos: ${response.body}"));
      }
    } catch (e) {
      final cachedRepos = await _loadReposFromCache();
      if (cachedRepos.isNotEmpty) {
        emit(RepoLoaded(cachedRepos));
      } else {
        emit(RepoError(state.repos, e.toString()));
      }
    } finally {
      isFetching = false;
    }
  }

  Future<void> _searchRepos(SearchReposEvent event, Emitter<RepoState> emit) async {
    // Reset state when searching
    currentPage = 1;
    emit(const RepoLoading([]));

    // Trigger fetch with search text
    add(FetchReposEvent(searchText: event.searchText));
  }

  Future<void> _openRepoUrl(OpenRepoUrlEvent event, Emitter<RepoState> emit) async {
    final url = event.url;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not open the URL: $url';
    }
  }

  Future<String> _getToken() async {
    final preferences = await prefs;
    return preferences.getString('github_token') ?? '';
  }

  Future<void> _saveReposToCache(List<Repo> repos) async {
    final preferences = await prefs;
    final List<Map<String, dynamic>> reposJson = repos.map((repo) => repo.toJson()).toList();
    await preferences.setString('cached_repos', json.encode(reposJson));
  }

  Future<List<Repo>> _loadReposFromCache() async {
    final preferences = await prefs;
    final cachedData = preferences.getString('cached_repos');
    if (cachedData != null) {
      final List<dynamic> jsonData = json.decode(cachedData);
      return jsonData.map((json) => Repo.fromJson(json)).toList();
    }
    return [];
  }
}