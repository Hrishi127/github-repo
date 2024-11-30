import 'package:equatable/equatable.dart';

abstract class GitHubTokenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GitHubTokenInitial extends GitHubTokenState {}

class GitHubTokenLoading extends GitHubTokenState {}

class GitHubTokenValid extends GitHubTokenState {
  final bool hasRepoScope;

  GitHubTokenValid(this.hasRepoScope);

  @override
  List<Object?> get props => [hasRepoScope];
}

class GitHubTokenInvalid extends GitHubTokenState {
  final String message;

  GitHubTokenInvalid(this.message);

  @override
  List<Object?> get props => [message];
}