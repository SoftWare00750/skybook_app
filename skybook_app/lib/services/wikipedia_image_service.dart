import 'dart:convert';
import 'package:http/http.dart' as http;

/// Looks up a representative photo for a city via Wikipedia's public REST
/// summary API (no API key required, and covered by Wikimedia's open
/// image licensing).
///
/// Used as a fallback in `DestinationImages` for airports that aren't in
/// the small hand-curated Unsplash map, so *every* airport in
/// `airports.dart` can show a real destination photo instead of just the
/// generic placeholder.
class WikipediaImageService {
  WikipediaImageService._();

  /// In-memory cache so the same city isn't looked up twice in one app
  /// session. Maps a lookup key to the resolved image URL, or null if no
  /// image was found for that city.
  static final Map<String, String?> _cache = {};

  /// Returns an image URL for [city], or null if no suitable Wikipedia
  /// article/photo could be found. Tries "City" first, then falls back to
  /// "City, Country" for common cities (e.g. "Springfield") whose plain
  /// name resolves to a disambiguation page.
  static Future<String?> imageForCity(String city, {String? country}) async {
    final cacheKey = '$city|$country';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    String? url = await _lookup(city);
    if (url == null && country != null && country.isNotEmpty) {
      url = await _lookup('$city, $country');
    }
    _cache[cacheKey] = url;
    return url;
  }

  static Future<String?> _lookup(String title) async {
    try {
      final uri = Uri.https(
        'en.wikipedia.org',
        '/api/rest_v1/page/summary/${Uri.encodeComponent(title)}',
      );
      final response = await http.get(
        uri,
        headers: {
          // Wikimedia asks API clients to identify themselves.
          'User-Agent': 'SkybookApp/1.0 (https://github.com/SoftWare00750/skybook_app)',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Disambiguation pages ("Springfield" -> list of many towns) don't
      // have a useful lead photo.
      if (data['type'] == 'disambiguation') return null;

      final thumbnail = data['thumbnail'] as Map<String, dynamic>?;
      final source = thumbnail?['source'] as String?;
      if (source == null) return null;

      // Wikipedia's summary thumbnail defaults to a small width (e.g.
      // ".../320px-Foo.jpg"); request a larger rendition for a header
      // banner by bumping that size segment.
      return source.replaceFirstMapped(RegExp(r'/(\d+)px-'), (_) => '/900px-');
    } catch (_) {
      // Network error, timeout, or unexpected shape — treat as "no image"
      // so the caller can fall back gracefully.
      return null;
    }
  }
}
