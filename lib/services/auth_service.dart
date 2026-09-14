import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../config/app_config.dart';

class AuthResult {
  final bool success;
  final String? token;
  final String? fullName;
  final String? email;
  final String? errorMessage;

  AuthResult.ok({this.token, this.fullName, this.email})
      : success = true,
        errorMessage = null;

  AuthResult.error(this.errorMessage)
      : success = false,
        token = null,
        fullName = null,
        email = null;
}

/// Talks to the ASP.NET Core backend (see `/backend`) for account creation
/// and sign-in, and persists the returned JWT locally with
/// [SharedPreferences] so the session survives app restarts.
class AuthService {
  static const _tokenKey = 'skybook_auth_token';
  static const _nameKey = 'skybook_user_name';
  static const _emailKey = 'skybook_user_email';
  static const _guestKey = 'skybook_is_guest';

  Uri _endpoint(String path) => Uri.parse('${AppConfig.backendBaseUrl}$path');

  Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            _endpoint('/api/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': fullName,
              'email': email,
              'phone': phone,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      return await _handleAuthResponse(response);
    } catch (e) {
      return AuthResult.error(_friendlyError(e));
    }
  }

  Future<AuthResult> login({required String emailOrPhone, required String password}) async {
    try {
      final response = await http
          .post(
            _endpoint('/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'emailOrPhone': emailOrPhone,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      return await _handleAuthResponse(response);
    } catch (e) {
      return AuthResult.error(_friendlyError(e));
    }
  }

  /// Signs in (or silently signs up) with Google. Gets a Google ID token
  /// from the native Google Sign-In SDK, then hands it to the backend's
  /// `/api/auth/google`, which verifies it server-side and issues our own
  /// JWT — the Flutter app never trusts the Google token on its own.
  Future<AuthResult> loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
        // Required so Google returns an ID token (not just an access
        // token) — set AppConfig.googleServerClientId to your OAuth 2.0
        // *Web* client ID from Google Cloud Console. See README for setup.
        serverClientId: AppConfig.googleServerClientId.isEmpty ? null : AppConfig.googleServerClientId,
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.error('Google sign-in was cancelled.');
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        return AuthResult.error(
          "Google didn't return an ID token. Make sure AppConfig.googleServerClientId is set to a Web OAuth client ID.",
        );
      }

      final response = await http
          .post(
            _endpoint('/api/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(const Duration(seconds: 15));

      return await _handleAuthResponse(response);
    } catch (e) {
      return AuthResult.error(_friendlyError(e));
    }
  }

  /// Signs in (or silently signs up) with Facebook. Same pattern as
  /// Google: the native SDK gets an access token, the backend verifies it
  /// against Facebook's Graph API and issues our own JWT.
  Future<AuthResult> loginWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login(permissions: const ['email', 'public_profile']);

      if (result.status == LoginStatus.cancelled) {
        return AuthResult.error('Facebook sign-in was cancelled.');
      }
      if (result.status != LoginStatus.success || result.accessToken == null) {
        return AuthResult.error(result.message ?? 'Facebook sign-in failed.');
      }

      final accessToken = result.accessToken!.tokenString;
      final response = await http
          .post(
            _endpoint('/api/auth/facebook'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'accessToken': accessToken}),
          )
          .timeout(const Duration(seconds: 15));

      return await _handleAuthResponse(response);
    } catch (e) {
      return AuthResult.error(_friendlyError(e));
    }
  }

  Future<AuthResult> _handleAuthResponse(http.Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final token = body['token'] as String?;
      final fullName = body['fullName'] as String?;
      final email = body['email'] as String?;
      if (token != null) await _persistSession(token, fullName, email);
      return AuthResult.ok(token: token, fullName: fullName, email: email);
    }
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthResult.error(body['message']?.toString() ?? 'Something went wrong (${response.statusCode}).');
    } catch (_) {
      return AuthResult.error('Something went wrong (${response.statusCode}).');
    }
  }

  Future<void> _persistSession(String token, String? name, String? email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (name != null) await prefs.setString(_nameKey, name);
    if (email != null) await prefs.setString(_emailKey, email);
    // A real sign-in/sign-up always supersedes any earlier guest session.
    await prefs.remove(_guestKey);
  }

  Future<String?> currentToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> cachedFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  Future<String?> cachedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Whether there's an active, non-guest session (i.e. a stored JWT).
  Future<bool> isSignedIn() async {
    final token = await currentToken();
    return token != null && token.isNotEmpty;
  }

  /// Marks the session as a guest session — no backend call, no token.
  /// Clears any previous signed-in session first so the two states never
  /// overlap.
  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.setBool(_guestKey, true);
  }

  /// Whether the current session is a guest session (set by
  /// [continueAsGuest] and cleared by [logout] or a real [login]/[signup]).
  Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestKey) ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_guestKey);
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection')) {
      return "Can't reach the server. Is the SkyBook backend running at ${AppConfig.backendBaseUrl}?";
    }
    if (msg.contains('TimeoutException')) {
      return 'The server took too long to respond. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
