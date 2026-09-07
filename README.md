# SkyBook — Flight Booking App (Flutter)

A pixel-inspired Flutter clone of the SkyBook flight-booking UI mockups, covering every screen from sign-in through booking confirmation and account management.

## What's new since the first version

- **Real logo** on the Welcome screen, from `assets/images/logo.png`.
- **Live sign in / sign up** against the companion .NET backend in
  `../skybook_backend` (Supabase-backed user accounts + JWT).
- **Destination photos** on Search Results and Flight Details, hotlinked
  from Unsplash and keyed by arrival airport code (`lib/data/destination_images.dart`).
- **Live flight search** via aviationstack.com, with automatic fallback to
  the bundled sample flights if no API key is configured or the request
  fails (`lib/services/aviationstack_service.dart`).

## Configuration

Edit `lib/config/app_config.dart`, or pass values at run time:

```bash
flutter run \
  --dart-define=BACKEND_BASE_URL=http://localhost:5236 \
  --dart-define=AVIATIONSTACK_API_KEY=your_aviationstack_key
```

Without an aviationstack key, Search Results still works and shows the
sample flights with a small notice banner explaining why. Without the
backend running, Sign In / Sign Up will show a friendly connection error
instead of crashing.

See `../skybook_backend/README.md` for how to stand up the .NET + Supabase
side.

## Screens included

**Onboarding & Auth**
- Welcome / Sign In
- Create Account (Sign Up)
- Travel Without Limits (guest onboarding)

**Search & Booking**
- Home (flight search form + popular destinations)
- Search Results (filters/sort + flight list)
- Flight Details (fare summary)
- Passenger Details
- Seat Selection (interactive seat map)
- Payment (method picker)
- Add New Card
- Booking Confirmed

**Account**
- My Bookings (Upcoming / Past)
- Profile
- My Wallet (balance + transactions)
- My Trips (Upcoming / Past)
- Settings
- Notifications
- Support Center
- Help & FAQ

Navigation runs through a shared 5-tab bottom bar (Home · Bookings · Trips · Wallet · Profile), matching the mockup.

## Project structure

```
lib/
  main.dart                  # App entry point
  theme/app_theme.dart       # Colors, radii, ThemeData (red/white design system)
  models/flight.dart         # Flight data model + sample data
  widgets/                   # Shared buttons, text fields, bottom nav, flight card
  screens/
    auth/                    # Welcome, Signup, Onboarding
    home/                    # Home search screen
    search/                  # Search results, flight details
    booking/                 # Passenger details, seats, payment, add card, confirmation
    bookings/                # My Bookings
    profile/                 # Profile
    wallet/                  # Wallet
    trips/                   # My Trips
    settings/                # Settings
    notifications/           # Notifications
    support/                 # Support Center, Help & FAQ
```

## Running it

You'll need the Flutter SDK installed locally (this sandbox doesn't have it, so the project hasn't been compiled here — review the code before running, though it's been checked for structural/syntax consistency).

```bash
flutter pub get
flutter run
```

Works on iOS, Android, and web out of the box (Material 3, no platform-specific code).

## Notes

- All data (flights, bookings, transactions) is static/sample data — there's no backend. Wire up an API layer in place of `models/flight.dart`'s `sampleFlights` and the hardcoded lists in each screen to make it live.
- The seat map, tab switches (Upcoming/Past, One way/Round trip/Multi-city), payment method selection, and card form are fully interactive with local state.
- Colors/spacing live in `theme/app_theme.dart` — tweak `AppColors.primary` to reskin the whole app.
