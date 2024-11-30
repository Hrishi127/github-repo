class Repo {
  final String name;
  final String? description;
  final int stargazersCount;
  final int forksCount;
  final DateTime? lastUsed;
  final String url;

  Repo({
    required this.name,
    required this.description,
    required this.stargazersCount,
    required this.forksCount,
    required this.lastUsed,
    required this.url
  });

  // Factory method to create a Repo from a JSON map
  factory Repo.fromJson(Map<String, dynamic> json) {
    return Repo(
      name: json['name'] ?? '',
      description: json['description'],
      stargazersCount: json['stargazers_count'] ?? 0,
      forksCount: json['forks_count'] ?? 0,
      lastUsed: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      url: json['html_url']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'stargazers_count': stargazersCount,
      'forks_count': forksCount,
      'last_used': lastUsed?.toIso8601String(),
      'html_url' : url
    };
  }
}