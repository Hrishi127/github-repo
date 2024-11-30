import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/github_service.dart';
import 'repo_event.dart';
import 'repo_state.dart';

class RepoBloc extends Bloc<RepoEvent, RepoState> {
  final GitHubService gitHubService;

  RepoBloc(this.gitHubService) : super(RepoInitial()) {
    on<LoadRepos>(_onLoadRepos);
  }

  Future<void> _onLoadRepos(LoadRepos event, Emitter<RepoState> emit) async {
    try {
      emit(RepoLoading());
      final repos = await gitHubService.fetchRepos();
      emit(RepoLoaded(repos));
    } catch (e) {
      emit(RepoError("Failed to load repositories: $e"));
    }
  }
}