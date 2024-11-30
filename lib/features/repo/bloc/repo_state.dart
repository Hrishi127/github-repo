import '../models/github_repo.dart';

abstract class RepoState {}

class RepoInitial extends RepoState {}

class RepoLoading extends RepoState {}

class RepoLoaded extends RepoState {
  final List<GitHubRepo> repos;

  RepoLoaded(this.repos);
}

class RepoError extends RepoState {
  final String message;

  RepoError(this.message);
}