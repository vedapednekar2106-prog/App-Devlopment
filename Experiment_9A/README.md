# Experiment 9: Flutter Calculator with SQLite Database

## Aim
To create a Flutter calculator app that **stores calculation history locally using SQLite**, allowing the user to insert, retrieve, update, and delete past calculations. The app also stores **additional fields** like date and note for each calculation.

---

## Steps Followed

1. **Project Setup**
   - Created a new Flutter project.
   - Added dependencies in `pubspec.yaml`:
     ```yaml
     dependencies:
flutter:
sdk: flutter

cupertino_icons: ^1.0.8

# ✅ Local database packages
sqflite: ^2.3.3+1
path_provider: ^2.1.2


2. **Database Helper Class (`db_helper.dart`)**
   - Created `DBHelper` class to manage SQLite database.
   - Defined table `calculations` with columns:
      - `id` (Primary Key)
      - `expression` (calculation expression)
      - `result` (calculated result)
      - `date` (timestamp of calculation)
      - `note` (description or note for calculation)
   - Implemented CRUD functions: `insertCalculation`, `getCalculations`, `updateCalculation`, `deleteCalculation`.

3. **Main Calculator Page (`main.dart`)**
   - Created calculator UI with buttons for numbers and operations.
   - Implemented calculation logic using `math_expressions` package.
   - After every calculation, inserted record into SQLite database with default note `"Manual calculation"` and current date.
   - Added AppBar button to navigate to **History Page**.

4. **History Page**
   - Displayed all saved calculations using `ListView`.
   - Provided **Edit** and **Delete** buttons for each record.
   - On editing, updated the `note` field (default `"Updated note"` in code).
   - On deleting, removed the record from the database.

---

## Expected Output

1. **Calculator Page**
   - User can perform calculations normally.
   - Each calculation is automatically stored in SQLite with date and note.

2. **History Page**
   - Displays a list of all past calculations in descending order (latest first).
   - Each record shows:
      - Expression (e.g., `2+3`)
      - Result (e.g., `5`)
      - Date (e.g., `2025-10-18 12:34:56`)
      - Note (e.g., `Manual calculation` or `Updated note`)
   - User can **edit the note** or **delete the record**.

3. **Data Persistence**
   - Calculation history persists even after closing or restarting the app.

---

## Outcome
A fully functional Flutter calculator with **persistent storage** using SQLite and **interactive history management**, suitable for real-world applications or database experiments.