/// Central place for every external endpoint / secret the app needs.
///
/// Nothing here is a real credential — fill these in for your own
/// environment before running the app "for real":
///
/// 1. [backendBaseUrl] — where your SkyBook .NET API (see /backend) is
///    running. Defaults to the standard local `dotnet run` address.
///    For Android emulators, `localhost` must be `10.0.2.2` instead.
/// 2. [aviationstackApiKey] — get a free key at https://aviationstack.com/
///    after signing up, then either paste it here or (recommended) pass it
///    at build/run time with:
///      flutter run --dart-define=AVIATIONSTACK_API_KEY=your_key_here
class AppConfig {
  /// Base URL of the ASP.NET Core backend (see the `/backend` folder).
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:5236',
  );

  /// aviationstack.com API key. aviationstack's free tier only supports
  /// plain HTTP, not HTTPS — upgrade your aviationstack plan for HTTPS.
  static const String aviationstackApiKey = String.fromEnvironment(
    'AVIATIONSTACK_API_KEY',
    defaultValue: '',
  );

  static bool get hasAviationstackKey => aviationstackApiKey.isNotEmpty;
}
