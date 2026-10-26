# CampusCare — Campus Incident Reporting System

IT 110 — Web Systems and Technologies
Laboratory Activity No. 9: Report Form Screen and Four Essential Flutter Web UI States

This repository contains the Activity 8 baseline structure (Login, Home, shared
button and text-field widgets) extended with the Activity 9 report form.

## Run the project

```bash
flutter pub get
flutter run -d chrome
```

The app opens on the Login screen. Use the prefilled demo account:

- Email: `student@campuscare.edu`
- Password: `campuscare123`

You can also choose **Skip to dashboard (demo)**.

## Activity 9 features

| Requirement | Where it lives |
|---|---|
| New report screen | `lib/screens/report_form_screen.dart` |
| Route from existing navigation | `lib/app.dart` (`/report`, `/reports`), `lib/screens/home_screen.dart` |
| Shared action button | `lib/widgets/app_button.dart` (Login, Home, report form, state panels) |
| Shared text field | `lib/widgets/app_text_field.dart` (Login and report form) |
| Validation | Title, category, location, and description validators in `report_form_screen.dart` |
| Loading state | 10-second simulated submission with spinner, disabled submit button, and loading banner |
| Success state | Confirmation panel with reference number and next actions |
| Empty state | Saved reports view before the first submission |
| Error state | Simulated failure switch, error explanation, Retry, and Review form |
| Simulated backend | `lib/services/report_service.dart` — in-memory only, no REST API or PostgreSQL yet |

## Reproduce the four states

1. **Loading** — open the report form, fill every required field, press
   **Submit report**, and capture the screen during the 10-second delay.
2. **Success** — let the same request finish; the confirmation panel shows the
   generated reference and the next actions.
3. **Empty** — open **Saved reports** from Home (or the screen's tab) before
   submitting anything. The list contains zero records.
4. **Error** — turn on **Simulate a failed submission**, submit a valid form,
   then use **Retry submission**. Retry turns the simulation off so the demo
   recovers to Success.

All four responses are simulated with `Future.delayed`. Reports are stored in
memory and disappear on a full page reload.

## Project structure

```text
lib/
  main.dart
  app.dart
  constants/
    app_constants.dart
  models/
    report.dart
  routes/
    app_routes.dart
  screens/
    home_screen.dart
    login_screen.dart
    report_form_screen.dart   <-- new for Activity 9
  services/
    report_service.dart
  widgets/
    app_button.dart
    app_text_field.dart
    status_panel.dart
```

## Tests

```bash
flutter analyze
flutter test
```

The widget tests cover field-level validation, Loading -> Success, duplicate
submission prevention, simulated Error -> Retry -> Success, the Empty state,
and Login -> Home navigation.
