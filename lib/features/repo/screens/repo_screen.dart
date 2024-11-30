import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_repo/core/colors.dart';
import 'package:github_repo/features/github_token/bloc/github_token_bloc.dart';
import 'package:github_repo/features/github_token/bloc/github_token_event.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/repo.dart';
import '../bloc/repo_bloc.dart';
import '../bloc/repo_event.dart';
import '../bloc/repo_state.dart';

class RepoScreen extends StatelessWidget {
  const RepoScreen({super.key});

  @override
  Widget build(BuildContext context) {

    context.read<RepoBloc>().add(const FetchReposEvent());

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Repositories'),
        actions: [
          BlocProvider(
            create: (context) => GitHubTokenBloc(),
            child: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text("Logout"),
                  onTap: () => context.read<GitHubTokenBloc>().add(LogoutEvent()),
                ),
              ],
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search global repositories...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    context.read<RepoBloc>().add(SearchReposEvent(context.read<RepoBloc>().searchController.text.trim()));
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (value) {
                context.read<RepoBloc>().add(SearchReposEvent(value.trim())
                );
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<RepoBloc, RepoState>(
        builder: (context, state) {
          // Handle loading states
          if (state is RepoLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is RepoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RepoBloc>().add(const FetchReposEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Prepare the list of repositories
          final repos = state.repos;

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                // Trigger load more when scrolled to bottom
                context.read<RepoBloc>().add(FetchReposEvent(searchText: context.read<RepoBloc>().searchController.text.trim()));
                return true;
              }
              return false;
            },
            child: ListView.builder(
              controller: context
                  .read<RepoBloc>()
                  .scrollController,
              itemCount: repos.length + (state is RepoLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Handle loading more indicator
                if (index >= repos.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final repo = repos[index];
                return _buildRepoListItem(context, repo);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRepoListItem(BuildContext context, Repo repo) {
    return Material(
      color: backgroundColor,
      child: ListTile(
        title: Text(
          repo.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (repo.description != null)
              Text(
                repo.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.star_border, size: 16),
                Text(' ${repo.stargazersCount}'),
                const SizedBox(width: 10),
                const Icon(Icons.fork_right, size: 16),
                Text(' ${repo.forksCount}'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_browser),
          onPressed: () {
            // Open repository URL
            context.read<RepoBloc>().add(OpenRepoUrlEvent(repo.url));
          },
        ),
        onTap: () {
          // Optional: Add navigation to repository details
          _showRepositoryDetails(context, repo);
        },
      ),
    );
  }

  void _showRepositoryDetails(BuildContext context, Repo repo) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                repo.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (repo.description != null)
                Text(
                  repo.description!,
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 16,),
                  const SizedBox(width: 8),
                  Text('Created: ${repo.lastUsed != null ? timeago.format(repo.lastUsed!) : 'Unknown'}'),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Open repository URL
                  context.read<RepoBloc>().add(OpenRepoUrlEvent(repo.url));
                  Navigator.pop(context);
                },
                child: const Text('View on GitHub'),
              ),
            ],
          ),
        );
      },
    );
  }
}
