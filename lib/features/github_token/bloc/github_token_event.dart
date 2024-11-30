import 'package:equatable/equatable.dart';

abstract class GitHubTokenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ValidateTokenEvent extends GitHubTokenEvent {
  final String token;

  ValidateTokenEvent(this.token);

  @override
  List<Object?> get props => [token];
}

class LogoutEvent extends GitHubTokenEvent {}