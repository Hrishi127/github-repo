import 'package:equatable/equatable.dart';

abstract class RepoEvent extends Equatable {
  const RepoEvent();

  @override
  List<Object> get props => [];
}

class FetchReposEvent extends RepoEvent {
  final String? searchText;

  const FetchReposEvent({this.searchText});

  @override
  List<Object> get props => [searchText ?? ''];
}

class OpenRepoUrlEvent extends RepoEvent {
  final String url;

  const OpenRepoUrlEvent(this.url);

  @override
  List<Object> get props => [url];
}

class SearchReposEvent extends RepoEvent {
  final String searchText;

  const SearchReposEvent(this.searchText);

  @override
  List<Object> get props => [searchText];
}