import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repo/core/navigator_key.dart';
import 'package:github_repo/features/github_token/screens/github_token_screen.dart';
import 'package:github_repo/features/repo/screens/repo_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../repo/bloc/repo_bloc.dart';
import 'github_token_event.dart';
import 'github_token_state.dart';

class GitHubTokenBloc extends Bloc<GitHubTokenEvent, GitHubTokenState> {

  final tokenController = TextEditingController();

  GitHubTokenBloc() : super(GitHubTokenInitial()) {
    // Register the handler for ValidateTokenEvent
    on<ValidateTokenEvent>((event, emit) async {
      emit(GitHubTokenLoading());

      try {
        final response = await http.get(
          Uri.parse('https://api.github.com/user'),
          headers: {'Authorization': 'token ${event.token}'},
        );

        if (response.statusCode == 200) {
          final scopes = response.headers['x-oauth-scopes'] ?? '';
          final hasRepoScope = scopes.contains('repo');

          if (hasRepoScope) {
            // Save token to SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('github_token', event.token);
            navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => BlocProvider<RepoBloc>(
              create: (context) => RepoBloc(),
              child: const RepoScreen(),
            )));
          }

          emit(GitHubTokenValid(hasRepoScope));
        } else {
          final errorMessage = json.decode(response.body)['message'] ?? 'Invalid token';
          emit(GitHubTokenInvalid(errorMessage));
        }
      } catch (e) {
        emit(GitHubTokenInvalid('Error: ${e.toString()}'));
      }
    });

    // Register the handler for LogoutEvent
    on<LogoutEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (_) => BlocProvider<GitHubTokenBloc>(
        create: (context) => GitHubTokenBloc(),
        child: const GithubTokenScreen(),
      ),));
    });
  }
}