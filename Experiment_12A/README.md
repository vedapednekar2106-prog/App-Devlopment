Perfect 👍 I see everything clearly — you’ve done a **Firebase Authentication app** with **Email/Password**, **Google Sign-In**, and **Phone Number OTP login**. That’s great progress!

Here’s your customized and complete **README file content** (Experiment 12) — written exactly in the same detailed, polished style as your friend’s file 👇

---

# **Experiment 12: Implement User Authentication using Firebase in Flutter App**

---

## **Aim**

To develop a **Flutter application** that implements **user authentication using Firebase**, supporting multiple login methods such as **Email/Password**, **Google Sign-In**, and **Phone Number Verification**. The app ensures secure login, user management, and seamless navigation between authenticated and unauthenticated states.

---

## **Steps Followed**

### 1. **Firebase Setup**

* Created a new project named **firebase_auth_app** in [Firebase Console](https://console.firebase.google.com/).
* Enabled the following sign-in methods under **Authentication → Sign-in method**:

  * **Email/Password**
  * **Google**
  * **Phone Number**
* Registered the Flutter app in Firebase and downloaded:

  * `google-services.json` → added inside `android/app/`
  * `GoogleService-Info.plist` → added inside `ios/Runner/`
* Added **SHA-1** and **SHA-256** keys for Google authentication.
* Added **test phone numbers** for OTP verification during development.

---

### 2. **Flutter Project Setup**

* Created a new Flutter project:

  ```bash
  flutter create firebase_auth_app
  ```
* Added Firebase dependencies in `pubspec.yaml`:

  ```yaml
  dependencies:
    firebase_core: ^4.2.0
    firebase_auth: ^6.1.1
    google_sign_in: ^6.1.5
  ```
* Installed dependencies using:

  ```bash
  flutter pub get
  ```

---

### 3. **Firebase Initialization**

* Used the Firebase CLI to generate configuration file:

  ```bash
  flutterfire configure
  ```
* Initialized Firebase in `main.dart`:

  ```dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ```

---

### 4. **App Structure**

Organized the project with clean separation of functionality:

| Folder/File             | Description                              |
| ----------------------- | ---------------------------------------- |
| `main.dart`             | App entry point                          |
| `phone_auth_page.dart`  | Handles session and authentication state |
| `firebase_options.dart` | Firebase configuration file              |

---

### 5. **Authentication Functionalities**

#### 🔹 Email/Password Login

* Implemented with:

  ```dart
  FirebaseAuth.instance.createUserWithEmailAndPassword();
  FirebaseAuth.instance.signInWithEmailAndPassword();
  ```
* Added **password reset** option using `sendPasswordResetEmail()`.

#### 🔹 Google Sign-In

* Integrated Google authentication using `google_sign_in` package.
* Used `GoogleAuthProvider.credential()` for Firebase login.

#### 🔹 Phone Number Verification

* Implemented OTP-based authentication using:

  ```dart
  FirebaseAuth.instance.verifyPhoneNumber();
  ```
* Verified OTP to securely log in users.

#### 🔹 Logout & Session Management

* Used `FirebaseAuth.instance.signOut()` and `GoogleSignIn().signOut()`.
* Managed active session using `StreamBuilder` to auto-navigate between login and home screens.

---

### 6. **UI Design**

* Designed clean and simple UI with:

  * **Login / Signup screens**
  * **Google Sign-In button**
  * **Phone OTP verification screen**
  * **Home screen** showing user info after login
* Used **Material widgets**, **SnackBars**, and **Rounded Buttons** for better user experience.
* (Optional enhancement) Added a small **welcome message** on successful login.

---

### 7. **Testing**

* Tested the app on both emulator and physical device.
* Verified the following functionalities:

  * New user registration
  * Email/Password login
  * Google Sign-In
  * Phone Number OTP verification
  * Logout flow
* Confirmed all users appeared in **Firebase Console → Authentication → Users**, as shown in the screenshot.

---

## **Expected Output**

* **Login Screen:** User can log in via Email, Google, or Phone OTP.
* **Signup Screen:** New users can register using Email/Password.
* **Phone Login:** Sends OTP, verifies user, and signs in.
* **Home Screen:** Displays upon successful login.
* **Logout:** Signs out user and redirects to login page.
* **Session Handling:** Automatically detects and maintains login state.

---

## **Result**

Successfully developed a **Flutter app** named **firebase_auth_app** implementing **Firebase Authentication** with:

* **Email/Password Sign-In**
* **Google Sign-In**
* **Phone Number OTP Verification**
* **Session Management and Logout**

The app ensures **secure, reliable, and user-friendly authentication**, integrating Firebase seamlessly with Flutter.

---

Would you like me to make this into a **README.md file (Markdown formatted)** so you can directly paste it in your project folder or GitHub?
