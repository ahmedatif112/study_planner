# My Study Planner

A Flutter mobile app that helps a student plan study goals. The student can add goals, mark them as done, delete them, and see live statistics. Goals are saved on the phone, so they are still there when the app is reopened.

Built for the Mobile App Development (Dart & Flutter) final project at UNILAK.

## Features

- Add a study goal (subject and planned hours) on a separate screen
- Input validation: subject cannot be empty, hours must be a number greater than 0
- Mark a goal as done (strike-through) or undo it
- Delete a goal
- Live statistics: total hours, completed goals, remaining goals
- Friendly message when there are no goals
- Data is saved in a local SQLite database and survives closing the app

## Project Phases

| Phase | Title | What it covers |
|-------|-------|----------------|
| 1 | Static Screen | AppBar, heading, fixed goal cards, floating button |
| 2 | Working List | StatefulWidget, list of Maps, add / toggle / delete with `setState()` |
| 3 | Statistics & Cards | Getters with `fold()` and `where()`, one reusable `SummaryCard` widget |
| 4 | Second Screen | `AddGoalScreen`, `Navigator.push` / `pop`, form validation |
| 5 | Database Persistence | SQLite with `sqflite`, separate `database_helper.dart` |

## Project Structure

```
lib/
  main.dart             UI screens and app logic (STATIC / LOGIC / CONNECTION comments)
  database_helper.dart  All database code (init, insert, get, update, delete)
pubspec.yaml            Dependencies
```

## How Data Is Saved and Loaded

- **Start:** `main()` calls `DatabaseHelper.initDatabase()`, which opens (or creates) `goals.db` and the `goals` table.
- **Load:** `initState()` calls `_loadGoals()`, which reads all rows with `getGoals()` and shows them on screen.
- **Add:** the new goal is inserted with `insertGoal()`; the returned `id` is stored in the goal's Map.
- **Toggle:** `updateGoal(id, done)` changes the database, then `setState()` updates the screen.
- **Delete:** `deleteGoal(id)` removes the row, then the goal is removed from the screen.
- **bool vs int:** SQLite has no true/false, so `done` is saved as `1` or `0` and converted back when loading.

### Database table: `goals`

| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER | Primary key, auto-increment |
| subject | TEXT | Name of the subject |
| hours | INTEGER | Planned study hours |
| done | INTEGER | 0 = not done, 1 = done |

## Technologies

- Flutter and Dart
- `sqflite` (SQLite database for Android and iOS)
- `path` (builds the database file path)

## How to Run

1. Install Flutter and set up an Android device or emulator.
2. Clone the repository:
   ```
   git clone https://github.com/ahmedatif112/study_planner.git
   ```
3. Go into the project folder and install the packages:
   ```
   cd study_planner
   flutter pub get
   ```
4. Run the app on an Android device or emulator:
   ```
   flutter run
   ```

Note: `sqflite` does not run on Chrome or Windows desktop, so use an Android device or emulator.

## Author

Ahmed Atif Abdalla (GitHub: [ahmedatif112](https://github.com/ahmedatif112))