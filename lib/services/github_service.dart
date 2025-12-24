import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  static const String _baseUrl = 'https://api.github.com';

  final String? token;
  final String? owner;
  final String? repo;

  GitHubService({
    this.token,
    this.owner,
    this.repo,
  });

  bool get isConfigured =>
      token != null &&
      token!.isNotEmpty &&
      owner != null &&
      owner!.isNotEmpty &&
      repo != null &&
      repo!.isNotEmpty;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/vnd.github.v3+json',
    'Content-Type': 'application/json',
  };

  /// Read a file from the repository
  Future<GitHubFileResult> readFile(String path) async {
    if (!isConfigured) {
      return GitHubFileResult.error('GitHub not configured');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$path'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = utf8.decode(base64.decode(data['content'].replaceAll('\n', '')));
        return GitHubFileResult.success(
          content: content,
          sha: data['sha'],
        );
      } else if (response.statusCode == 404) {
        return GitHubFileResult.notFound();
      } else {
        return GitHubFileResult.error('Failed to read file: ${response.statusCode}');
      }
    } catch (e) {
      return GitHubFileResult.error('Error reading file: $e');
    }
  }

  /// Write or update a file in the repository
  Future<GitHubWriteResult> writeFile({
    required String path,
    required String content,
    required String message,
    String? sha,
  }) async {
    if (!isConfigured) {
      return GitHubWriteResult.error('GitHub not configured');
    }

    try {
      final body = {
        'message': message,
        'content': base64.encode(utf8.encode(content)),
        if (sha != null) 'sha': sha,
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$path'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return GitHubWriteResult.success(sha: data['content']['sha']);
      } else {
        return GitHubWriteResult.error('Failed to write file: ${response.statusCode}');
      }
    } catch (e) {
      return GitHubWriteResult.error('Error writing file: $e');
    }
  }

  /// Sync workout data to GitHub
  Future<SyncResult> syncWorkouts(Map<String, dynamic> workoutsData) async {
    const path = 'data/workouts.json';

    // First, try to read existing file to get SHA
    final existingFile = await readFile(path);
    String? sha;
    if (existingFile.isSuccess) {
      sha = existingFile.sha;
    }

    // Write the updated data
    final writeResult = await writeFile(
      path: path,
      content: const JsonEncoder.withIndent('  ').convert(workoutsData),
      message: 'Sync workouts from CW Hybrid Training',
      sha: sha,
    );

    if (writeResult.isSuccess) {
      return SyncResult.success();
    } else {
      return SyncResult.error(writeResult.errorMessage ?? 'Unknown error');
    }
  }

  /// Sync body scans to GitHub
  Future<SyncResult> syncBodyScans(Map<String, dynamic> bodyScansData) async {
    const path = 'data/body_scans.json';

    final existingFile = await readFile(path);
    String? sha;
    if (existingFile.isSuccess) {
      sha = existingFile.sha;
    }

    final writeResult = await writeFile(
      path: path,
      content: const JsonEncoder.withIndent('  ').convert(bodyScansData),
      message: 'Sync body scans from CW Hybrid Training',
      sha: sha,
    );

    if (writeResult.isSuccess) {
      return SyncResult.success();
    } else {
      return SyncResult.error(writeResult.errorMessage ?? 'Unknown error');
    }
  }

  /// Sync plans to GitHub
  Future<SyncResult> syncPlans(Map<String, dynamic> plansData) async {
    const path = 'data/plans.json';

    final existingFile = await readFile(path);
    String? sha;
    if (existingFile.isSuccess) {
      sha = existingFile.sha;
    }

    final writeResult = await writeFile(
      path: path,
      content: const JsonEncoder.withIndent('  ').convert(plansData),
      message: 'Sync plans from CW Hybrid Training',
      sha: sha,
    );

    if (writeResult.isSuccess) {
      return SyncResult.success();
    } else {
      return SyncResult.error(writeResult.errorMessage ?? 'Unknown error');
    }
  }

  /// Read GPT feedback from GitHub
  Future<GitHubFileResult> readGptFeedback() async {
    return readFile('data/gpt_feedback.json');
  }

  /// Write GPT feedback to GitHub
  Future<SyncResult> syncGptFeedback(Map<String, dynamic> feedbackData) async {
    const path = 'data/gpt_feedback.json';

    final existingFile = await readFile(path);
    String? sha;
    if (existingFile.isSuccess) {
      sha = existingFile.sha;
    }

    final writeResult = await writeFile(
      path: path,
      content: const JsonEncoder.withIndent('  ').convert(feedbackData),
      message: 'Sync GPT feedback from CW Hybrid Training',
      sha: sha,
    );

    if (writeResult.isSuccess) {
      return SyncResult.success();
    } else {
      return SyncResult.error(writeResult.errorMessage ?? 'Unknown error');
    }
  }

  /// Sync all data to GitHub
  Future<SyncResult> syncAll({
    required Map<String, dynamic> workouts,
    required Map<String, dynamic> bodyScans,
    required Map<String, dynamic> plans,
    Map<String, dynamic>? gptFeedback,
  }) async {
    final results = await Future.wait([
      syncWorkouts(workouts),
      syncBodyScans(bodyScans),
      syncPlans(plans),
      if (gptFeedback != null) syncGptFeedback(gptFeedback),
    ]);

    final errors = results.where((r) => !r.isSuccess).toList();
    if (errors.isEmpty) {
      return SyncResult.success();
    } else {
      return SyncResult.error(errors.map((e) => e.errorMessage).join(', '));
    }
  }
}

class GitHubFileResult {
  final bool isSuccess;
  final bool isNotFound;
  final String? content;
  final String? sha;
  final String? errorMessage;

  GitHubFileResult._({
    required this.isSuccess,
    this.isNotFound = false,
    this.content,
    this.sha,
    this.errorMessage,
  });

  factory GitHubFileResult.success({required String content, required String sha}) {
    return GitHubFileResult._(isSuccess: true, content: content, sha: sha);
  }

  factory GitHubFileResult.notFound() {
    return GitHubFileResult._(isSuccess: false, isNotFound: true);
  }

  factory GitHubFileResult.error(String message) {
    return GitHubFileResult._(isSuccess: false, errorMessage: message);
  }
}

class GitHubWriteResult {
  final bool isSuccess;
  final String? sha;
  final String? errorMessage;

  GitHubWriteResult._({
    required this.isSuccess,
    this.sha,
    this.errorMessage,
  });

  factory GitHubWriteResult.success({required String sha}) {
    return GitHubWriteResult._(isSuccess: true, sha: sha);
  }

  factory GitHubWriteResult.error(String message) {
    return GitHubWriteResult._(isSuccess: false, errorMessage: message);
  }
}

class SyncResult {
  final bool isSuccess;
  final String? errorMessage;

  SyncResult._({required this.isSuccess, this.errorMessage});

  /// Alias for errorMessage for convenience
  String? get error => errorMessage;

  factory SyncResult.success() {
    return SyncResult._(isSuccess: true);
  }

  factory SyncResult.error(String message) {
    return SyncResult._(isSuccess: false, errorMessage: message);
  }
}
