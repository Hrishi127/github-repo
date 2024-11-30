import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/github_repo.dart';

class GitHubService {
  final String accessToken;

  GitHubService(this.accessToken);

  Future<List<GitHubRepo>> fetchRepos() async {
    final response = await http.get(
      Uri.parse('https://api.github.com/user/repos'),
      headers: {
        'Authorization': 'token $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((repo) => GitHubRepo.fromJson(repo)).toList();
    } else {
      throw Exception('Failed to load repositories ${response.body} $accessToken');
    }
  }
}