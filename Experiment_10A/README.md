# Experiment 10: Firebase Calculator App (Flutter)

## Experiment Aim
To develop a **Flutter calculator app** that performs basic arithmetic operations and **stores/retrieves calculation history using Firebase Firestore**, enabling users to access their previous calculations across devices.

---

## Steps Followed

1. **Project Setup**
    - Created a new Flutter project:
      ```bash
      flutter create calculator_app

      ```
    - Added dependencies in `pubspec.yaml`:
      ```yaml
      dependencies:
      flutter:
      sdk: flutter
      math_expressions: ^2.0.1
      firebase_core: ^3.5.0
      cloud_firestore: ^5.4.3

      ```
    - Ran `flutter pub get` to install dependencies.

2. **Firebase Setup (Flutter)**
    - Created a Firebase project in [Firebase Console](https://console.firebase.google.com/).
    - Chose **Flutter** when running `flutterfire configure`.
    - This generated **`firebase_options.dart`**, which contains platform-specific Firebase configurations for Android, iOS, Web, macOS, and Windows.

3. **Firebase Initialization**
    - Initialized Firebase in `main.dart` before running the app:
      ```dart
      import 'package:flutter/material.dart';
      import 'package:firebase_core/firebase_core.dart';
      import 'firebase_options.dart';
      import 'calculator_screen.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);
runApp(const MyApp());
}


4. **Calculator Functionality**
    - Implemented arithmetic operations: addition, subtraction, multiplication, division.
    - Used the `math_expressions` package to evaluate expressions.
    - Managed input/output via buttons and display widgets.
    - Used `StatefulWidget` to manage the app state.

5. **Storing and Retrieving Data**
    - Each calculation is saved to **Firestore** with:
        - `expression`
        - `result`
        - `timestamp`
      ```dart
      await FirebaseFirestore.instance.collection('calculations').add({
       'expression': expression,
       'result': result.toString(),
       'timestamp': FieldValue.serverTimestamp(),
      });

      ```
    - Calculation history is fetched in real-time using `StreamBuilder` and displayed in a `ListView`.

6. **UI Design**
    - Black background with white text for display.
    - Grid layout for calculator buttons.
    - Color-coded buttons:
        - Numbers: dark grey
        - Operators: orange
        - Clear (C): red
        - Equals (=): green
    - Responsive design for multiple screen sizes.

7. **Testing**
    - Verified calculations on Android and iOS simulators.
    - Confirmed that calculation history is correctly stored and retrieved from Firebase Firestore in real-time.

---

## Expected Outcome

- Fully functional Flutter calculator capable of basic arithmetic.
- Real-time storage and retrieval of calculation history from Firebase Firestore.
- Persistent history across app sessions and devices.
- Clean, responsive interface with color-coded buttons.
- Robust handling of errors (division by zero, invalid input).