import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'github_token_event.dart';
import 'github_token_state.dart';

class GitHubTokenBloc extends Bloc<GitHubTokenEvent, GitHubTokenState> {
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
  }
}