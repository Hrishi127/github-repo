abstract class RepoEvent {}

class LoadRepos extends RepoEvent {
  final String accessToken;

  LoadRepos(this.accessToken);
}