import 'package:equatable/equatable.dart';
import '../models/repo.dart';

abstract class RepoState extends Equatable {
  final List<Repo> repos;

  const RepoState(this.repos);

  @override
  List<Object?> get props => [repos];
}

class RepoLoading extends RepoState {
  const RepoLoading(super.repos);
}

class RepoLoadingMore extends RepoState {
  const RepoLoadingMore(super.repos);
}

class RepoLoaded extends RepoState {
  const RepoLoaded(super.repos);
}

class RepoError extends RepoState {
  final String message;

  const RepoError(super.repos, this.message);

  @override
  List<Object?> get props => [repos, message];
}