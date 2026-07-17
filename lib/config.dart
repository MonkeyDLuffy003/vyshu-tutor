/// All secrets are injected at build time via --dart-define, so nothing
/// sensitive is ever committed to your GitHub repo.
///
/// Locally (if you ever get a laptop/Codespaces terminal):
///   flutter run --dart-define=ANTHROPIC_API_KEY=sk-ant-xxx --dart-define=YOUTUBE_API_KEY=AIza-xxx
///
/// In GitHub Actions: store the keys as repo Secrets
/// (Settings -> Secrets and variables -> Actions) named
/// ANTHROPIC_API_KEY and YOUTUBE_API_KEY. The workflow file in
/// .github/workflows/build_apk.yml already wires these in for you.
class Config {
  static const String anthropicApiKey =
      String.fromEnvironment('ANTHROPIC_API_KEY', defaultValue: '');

  static const String youtubeApiKey =
      String.fromEnvironment('YOUTUBE_API_KEY', defaultValue: '');

  // Anthropic model used for tutoring + mock test generation.
  static const String model = 'claude-sonnet-5';

  static const String anthropicEndpoint = 'https://api.anthropic.com/v1/messages';
  static const String youtubeSearchEndpoint =
      'https://www.googleapis.com/youtube/v3/search';
}
