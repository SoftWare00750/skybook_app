# SkyBook — Flight Booking App (Flutter)

A Flutter flight-booking app covering everything from the welcome screen
through search, booking, and account management, backed by a real .NET +
Supabase API (`../skybook_backend`).

## What's here

- **Branded app icon** generated from the SkyBook emblem
  (`assets/images/logo.png`) — Android, iOS, and web icons are already in
  place under `android/`, `ios/`, and `web/`.
- **A real welcome/landing screen** (`lib/screens/auth/landing_screen.dart`)
  shown on first launch, before sign in / sign up / guest mode.
- **Live sign in / sign up / Google / Facebook** against the companion
  .NET backend (Supabase-backed user accounts + JWT). See
  **Google & Facebook sign-in setup** below — the code is fully wired, but
  the buttons will fail until you plug in real OAuth credentials, which
  only you can create under your own developer accounts.
- **172 airports across every populated continent**
  (`lib/data/airports.dart`) power the "From"/"To" pickers, with a working
  swap button, live search, and duplicate-prevention between the two
  fields.
- **Live flight search** via aviationstack.com, with automatic fallback to
  bundled sample flights if no API key is configured or the request fails.
- **Bookings, wallet, and profile all talk to the real backend** — not
  sample data — for signed-in users. Guests see a "sign in to see this"
  prompt instead of a broken network call, and can still complete a
  checkout with a locally generated (unsaved) booking reference.

## Configuration

Edit `lib/config/app_config.dart`, or pass values at run time:

```bash
flutter run \
  --dart-define=BACKEND_BASE_URL=https://skybook-api-m5ps.onrender.com \
  --dart-define=AVIATIONSTACK_API_KEY=your_aviationstack_key \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com \
  --dart-define=FACEBOOK_APP_ID=your_facebook_app_id
```

Without an aviationstack key, Search Results still works and shows the
sample flights with a small notice banner explaining why. Without the
backend reachable, sign in/up show a friendly connection error instead of
crashing.

## Google & Facebook sign-in setup

The Dart code (`AuthService.loginWithGoogle` / `.loginWithFacebook`, the
new `/api/auth/google` and `/api/auth/facebook` backend endpoints) is
complete and correct, but **cannot actually authenticate anyone until you
register real apps with Google and Facebook** — that's not something that
can be faked or skipped, by design. Checklist:

### Google
1. [Google Cloud Console](https://console.cloud.google.com/apis/credentials) → configure the OAuth consent screen.
2. Create **three** OAuth client IDs:
   - **Web application** — this is the "server client ID". Put it in
     *both* `AppConfig.googleServerClientId` (or `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`)
     *and* the backend's `Google:ClientId` config — it's what makes
     `google_sign_in` return a verifiable ID token at all.
   - **Android** — needs your app's package name (`com.example.skybook`
     by default; change it in `android/app/build.gradle` first if you
     haven't) and your debug/release **SHA-1** signing fingerprint
     (`cd android && ./gradlew signingReport`).
   - **iOS** — needs your bundle ID. Then replace
     `REPLACE_WITH_GOOGLE_REVERSED_CLIENT_ID` in `ios/Runner/Info.plist`
     with that client's "reversed client ID".

### Facebook
1. Create an app at [Meta for Developers](https://developers.facebook.com/apps) and add the **Facebook Login** product.
2. Under Settings → Basic, copy the **App ID** and **Client Token**, and
   fill them into:
   - `android/app/src/main/res/values/strings.xml` (`facebook_app_id`,
     `fb_login_protocol_scheme` = `"fb" + App ID`, `facebook_client_token`)
   - `ios/Runner/Info.plist` (`FacebookAppID`, `FacebookClientToken`, and
     the `fb<App ID>` URL scheme already scaffolded there)
3. Under Settings → Basic → Android/iOS platform entries, add your package
   name + key hash (Android) and bundle ID (iOS).
4. The backend needs **no** Facebook secret for this flow — it verifies
   the access token by calling the Graph API with it directly.

Until all of the above is done, tapping "Continue with Google/Facebook"
will show a clear error (cancelled / no ID token / invalid token) rather
than silently failing — that's intentional so it's obvious what's missing.

## Screens included

**Onboarding & Auth**
- Landing / Welcome (logo, Sign In / Create Account / Guest)
- Sign In (email/password, Google, Facebook)
- Create Account (email/password, Google, Facebook)
- Travel Without Limits (guest onboarding)

**Search & Booking**
- Home (flight search form: airport pickers, date pickers, passengers/class, swap)
- Search Results (filters/sort + flight list, backed by aviationstack)
- Flight Details (fare summary)
- Passenger Details
- Seat Selection (interactive seat map)
- Payment (method picker)
- Add New Card
- Booking Confirmed (creates a real booking via the backend when signed in)

**Account**
- My Bookings (Upcoming / Past — live from the backend)
- Profile (live trip stats, editable personal info)
- My Wallet (live balance + transactions, working "Add Money")
- My Trips (Upcoming / Past — live from the backend)
- Settings
- Notifications
- Support Center
- Help & FAQ

Navigation runs through a shared 5-tab bottom bar (Home · Bookings · Trips · Wallet · Profile).

## Project structure

```
lib/
  main.dart                  # App entry point
  theme/app_theme.dart       # Colors, radii, ThemeData (red/white design system)
  config/app_config.dart     # Backend URL, API keys, OAuth client IDs
  data/airports.dart         # 172-airport dataset for the From/To pickers
  data/destination_images.dart
  models/                    # Flight, Booking, Profile, Wallet
  services/                  # auth, booking, wallet, profile, aviationstack, api_client
  widgets/                   # Shared buttons (incl. Google/Facebook), text fields, bottom nav, flight card
  screens/
    auth/                    # Landing, sign-in, sign-up, guest onboarding
    home/                    # Home search screen + airport/passenger pickers
    search/                  # Search results, flight details
    booking/                 # Passenger details, seats, payment, add card, confirmation
    bookings/                # My Bookings
    profile/                 # Profile
    wallet/                  # Wallet
    trips/                   # My Trips
    settings/                # Settings
    notifications/           # Notifications
    support/                 # Support Center, Help & FAQ
assets/
  images/logo.png            # Full SkyBook wordmark (used on auth screens)
  icons/google.svg           # Official Google mark (simple-icons, CC0)
  icons/facebook.svg         # Official Facebook mark (simple-icons, CC0)
android/ ios/ web/           # Platform launcher icons already generated from the logo
```

## Running it

You'll need the Flutter SDK installed locally — this sandbox doesn't have
one available, so the project hasn't been compiled or run here. Everything
was checked by hand (bracket balance, imports, signatures) but please run:

```bash
flutter pub get
flutter analyze
flutter run
```

before trusting it fully.

## Notes

- Guests never hit JWT-protected endpoints — bookings/wallet/profile show
  a "sign in to see this" prompt instead.
- Colors/spacing live in `theme/app_theme.dart` — tweak `AppColors.primary`
  to reskin the whole app.
- The Android manifest now declares `INTERNET` permission explicitly,
  which release builds need for *any* network call (it isn't implied by
  debug builds the way it can seem to be during development).
