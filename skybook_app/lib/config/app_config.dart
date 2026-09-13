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
/// 3. [googleServerClientId] — an OAuth 2.0 **Web** client ID from Google
///    Cloud Console (Credentials -> Create Credentials -> OAuth client ID
///    -> Web application). This is what makes google_sign_in return an ID
///    token the backend can verify — it's needed even though the app
///    itself is mobile. You'll also need a separate Android/iOS OAuth
///    client registered against your app's package name + SHA-1
///    (Android) or bundle ID (iOS) for the native sign-in sheet to work at
///    all; see backend/README.md for the full checklist.
/// 4. [facebookAppId] / [facebookClientToken] — from your app at
///    https://developers.facebook.com/apps -> Settings -> Basic. These
///    also need to be duplicated into android/app/src/main/res/values/
///    strings.xml and ios/Runner/Info.plist for the native SDKs to read at
///    startup (flutter_facebook_auth requires this — see its docs).
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

  /// Web OAuth client ID used to request a Google ID token. Empty by
  /// default — Google Sign-In will still open, but won't be able to
  /// return an ID token (and the backend call will fail) until this is
  /// set. Pass it at run time instead of hardcoding it:
  ///   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  /// Facebook App ID, for reference from Dart code (e.g. error messages).
  /// The native SDK itself reads its copy from strings.xml / Info.plist,
  /// not from here — see the class doc comment above.
  static const String facebookAppId = String.fromEnvironment(
    'FACEBOOK_APP_ID',
    defaultValue: '',
  );

  static bool get hasGoogleClientId => googleServerClientId.isNotEmpty;
  static bool get hasFacebookAppId => facebookAppId.isNotEmpty;
}
