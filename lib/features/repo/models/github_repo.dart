class GitHubRepo {
  final String name;
  final String description;
  final int stars;
  final int forks;
  final String lastUsed;

  GitHubRepo({
    required this.name,
    required this.description,
    required this.stars,
    required this.forks,
    required this.lastUsed,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      name: json['name'] ?? 'No name',
      description: json['description'] ?? 'No description',
      stars: json['stargazers_count'] ?? 0,
      forks: json['forks_count'] ?? 0,
      lastUsed: json['updated_at'] ?? 'N/A', // Use updated_at as the last used date
    );
  }
}