import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/github_token_bloc.dart';
import '../bloc/github_token_event.dart';
import '../bloc/github_token_state.dart';

class GithubTokenScreen extends StatelessWidget {
  const GithubTokenScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('GitHub Token Checker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter GitHub Personal Access Token:'),
            const SizedBox(height: 16),
            TextField(
              controller: context.read<GitHubTokenBloc>().tokenController,
              decoration: const InputDecoration(
                hintText: 'Paste your token here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final token = context.read<GitHubTokenBloc>().tokenController.text.trim();
                if (token.isNotEmpty) {
                  context.read<GitHubTokenBloc>().add(ValidateTokenEvent(token));
                }
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 24),
            BlocBuilder<GitHubTokenBloc, GitHubTokenState>(
              builder: (context, state) {
                if (state is GitHubTokenLoading) {
                  return const CircularProgressIndicator();
                } else if (state is GitHubTokenValid) {
                  if(state.hasRepoScope){
                    return const Text('Token is valid and has "repo" scope!', style: TextStyle(color: Colors.green));
                  } else {
                    return const Text('Token is valid but does not have "repo" scope.', style: TextStyle(color: Colors.red));
                  }
                } else if (state is GitHubTokenInvalid) {
                  return Text('Error: ${state.message}', style: const TextStyle(color: Colors.red));
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}