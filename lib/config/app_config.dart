/// Central place for every external endpoint / secret the app needs.
///
/// Nothing here is a real credential — fill these in for your own
/// environment before running the app "for real":
///
/// 1. [backendBaseUrl] — where your SkyBook .NET API (see /backend) is
///    running. Defaults to the standard local `dotnet run` address.
///    For Android emulators, `localhost` must be `10.0.2.2` instead.
///        flutter run --dart-define=BACKEND_BASE_URL=https://skybook-api-m5ps.onrender.com
/// 2. [aviationstackApiKey] — get a free key at https://aviationstack.com/
///    after signing up, then either paste it here or (recommended) pass it
///    at build/run time with:
///      flutter run --dart-define=AVIATIONSTACK_API_KEY=812cf18b25c8707731796d2ef005b14e
class AppConfig {
  /// Base URL of the ASP.NET Core backend (see the `/backend` folder).
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://skybook-api-m5ps.onrender.com',
  );

  /// aviationstack.com API key. aviationstack's free tier only supports
  /// plain HTTP, not HTTPS — upgrade your aviationstack plan for HTTPS.
  static const String aviationstackApiKey = String.fromEnvironment(
    'AVIATIONSTACK_API_KEY',
    defaultValue: '812cf18b25c8707731796d2ef005b14e',
  );

  static bool get hasAviationstackKey => aviationstackApiKey.isNotEmpty;
}
