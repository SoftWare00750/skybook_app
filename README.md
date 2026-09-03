# SkyBook — Flight Booking App (Flutter)

A pixel-inspired Flutter clone of the SkyBook flight-booking UI mockups, covering every screen from sign-in through booking confirmation and account management.

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
