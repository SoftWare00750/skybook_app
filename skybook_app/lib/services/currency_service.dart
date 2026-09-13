import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A currency the person can display prices in.
///
/// [rateFromUsd] is "how many units of this currency equal 1 USD" — every
/// price in the app (flight fares, wallet balance, taxes, seat fees) is
/// stored and sent to the backend in USD, so this is purely a *display*
/// conversion. It never changes what actually gets charged or saved.
class Currency {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  final double rateFromUsd;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    required this.rateFromUsd,
  });
}

/// Fixed, illustrative snapshot FX rates relative to 1 USD. SkyBook (and
/// aviationstack's free tier) doesn't expose a live foreign-exchange feed,
/// so these are reasonable approximations good enough for showing prices
/// in a currency the person actually thinks in. Point [rateFromUsd] at a
/// live-rate provider (e.g. exchangerate.host) if/when the backend grows
/// one — nothing else in the app needs to change, since every screen
/// always converts from the single USD source of truth at display time.
const List<Currency> supportedCurrencies = [
  Currency(code: 'USD', symbol: '\$', name: 'US Dollar', flag: '🇺🇸', rateFromUsd: 1),
  Currency(code: 'GBP', symbol: '£', name: 'British Pound', flag: '🇬🇧', rateFromUsd: 0.79),
  Currency(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺', rateFromUsd: 0.92),
  Currency(code: 'NGN', symbol: '₦', name: 'Nigerian Naira', flag: '🇳🇬', rateFromUsd: 1530),
  Currency(code: 'GHS', symbol: 'GH₵', name: 'Ghanaian Cedi', flag: '🇬🇭', rateFromUsd: 15.2),
  Currency(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling', flag: '🇰🇪', rateFromUsd: 129),
  Currency(code: 'ZAR', symbol: 'R', name: 'South African Rand', flag: '🇿🇦', rateFromUsd: 17.8),
  Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳', rateFromUsd: 83.5),
  Currency(code: 'AED', symbol: 'AED', name: 'UAE Dirham', flag: '🇦🇪', rateFromUsd: 3.67),
  Currency(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar', flag: '🇨🇦', rateFromUsd: 1.36),
  Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', flag: '🇦🇺', rateFromUsd: 1.51),
  Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵', rateFromUsd: 149),
  Currency(code: 'CNY', symbol: 'CN¥', name: 'Chinese Yuan', flag: '🇨🇳', rateFromUsd: 7.24),
];

/// App-wide "which currency should prices display in" setting.
///
/// A plain singleton + [ChangeNotifier] (rather than a package like
/// Provider, which isn't a dependency here) is enough: the home screen's
/// currency picker is the only widget that needs to live-rebuild when the
/// selection changes, everything else (flight cards, fare summaries,
/// payment screens) reads [current] fresh the next time it's built —
/// which is exactly what happens since those are pushed as new routes
/// after the home screen.
class CurrencyService extends ChangeNotifier {
  CurrencyService._internal();
  static final CurrencyService instance = CurrencyService._internal();

  static const _prefsKey = 'selected_currency_code';

  Currency _current = supportedCurrencies.first;
  Currency get current => _current;

  bool _loaded = false;

  /// Restores the last-picked currency from disk. Safe to call more than
  /// once (e.g. once eagerly in `main()`, and defensively from a screen
  /// that might run before that finishes) — it's a no-op after the first
  /// successful load.
  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null) {
        _current = supportedCurrencies.firstWhere(
          (c) => c.code == saved,
          orElse: () => supportedCurrencies.first,
        );
      }
    } catch (_) {
      // Fall back to USD if prefs aren't available for some reason.
    }
    _loaded = true;
  }

  Future<void> setCurrency(Currency currency) async {
    _current = currency;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, currency.code);
    } catch (_) {
      // Selection still applies for the rest of this session even if it
      // can't be persisted.
    }
  }

  /// Converts a USD amount into the currently-selected display currency.
  double convert(double amountUsd) => amountUsd * _current.rateFromUsd;

  /// Formats a USD amount as a price string in the currently-selected
  /// currency, e.g. `$740.00`, `₦1,131,700`, `¥110,260`.
  ///
  /// [amountUsd] must already be non-negative — callers displaying a
  /// signed amount (e.g. a wallet debit) should format `amount.abs()` and
  /// add their own +/- prefix, same as before this existed.
  String format(double amountUsd) {
    final converted = convert(amountUsd);
    final decimals = _current.code == 'JPY' ? 0 : 2;
    final fixed = converted.toStringAsFixed(decimals);
    final dotIndex = fixed.indexOf('.');
    final wholePart = dotIndex == -1 ? fixed : fixed.substring(0, dotIndex);
    final fractionPart = dotIndex == -1 ? null : fixed.substring(dotIndex + 1);
    final grouped = _groupThousands(wholePart);
    final numberPart = fractionPart == null ? grouped : '$grouped.$fractionPart';
    // Multi-letter symbols (AED, GH₵, CA$, CN¥) read better with a space;
    // single-glyph symbols ($, £, €, ₦, ¥, ₹, R) sit flush against the
    // number, matching how those currencies are normally written.
    final needsSpace = _current.symbol.length > 2;
    return needsSpace ? '${_current.symbol} $numberPart' : '${_current.symbol}$numberPart';
  }

  String _groupThousands(String digits) {
    final reversed = digits.split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < reversed.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(',');
      buffer.write(reversed[i]);
    }
    return buffer.toString().split('').reversed.join();
  }
}
