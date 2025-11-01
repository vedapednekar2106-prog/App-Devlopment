Perfect 👍 Here’s your **modified README** — rewritten specifically for **your project** (`Firebase Login App in Jetpack Compose using Kotlin`) — **ready to paste** as Experiment 12C 👇

---

# 🧪 **Experiment 12C: Firebase Authentication App using Android Studio (Jetpack Compose)**

## 🎯 **Aim**

To develop an Android application using **Jetpack Compose** integrated with **Firebase Authentication** that allows users to sign up, sign in, and log in securely using **Email/Password**, **Google Sign-In**, and **Phone OTP Authentication**.

---

## 🔑 **Key Features**

* User registration using Email and Password
* Secure login and logout using Firebase Authentication
* Google Sign-In integration using OAuth 2.0
* Phone Number Authentication with OTP verification
* Firestore integration to store basic user info
* Modern **Jetpack Compose UI** (no XML)

---

## ⚙️ **1. Project Setup**

* Created a new **Android Studio project** using the `Empty Activity` template.
* Converted UI to **Jetpack Compose**.
* Added Firebase dependencies in `app/build.gradle`:

  ```gradle
  implementation(platform("com.google.firebase:firebase-bom:33.1.2"))
  implementation("com.google.firebase:firebase-auth-ktx")
  implementation("com.google.firebase:firebase-firestore-ktx")
  implementation("com.google.android.gms:play-services-auth:21.2.0")
  implementation("com.google.firebase:firebase-analytics-ktx")
  ```
* Applied the Google Services plugin:

  ```gradle
  id("com.google.gms.google-services")
  ```

---

## ☁️ **2. Firebase Console Setup**

1. Created a new project in **Firebase Console**.
2. Added the Android app using package name → `com.example.firebaselogin`.
3. Downloaded and placed `google-services.json` inside the **app/** folder.
4. Enabled the following authentication methods under
   **Build → Authentication → Sign-in method:**

   * Email/Password
   * Google
   * Phone
5. Added **SHA-1** and **SHA-256** fingerprints for Google Sign-In support.
6. Copied the **Web Client ID** from Firebase and added it in the app code under:

   ```kotlin
   .requestIdToken("YOUR_WEB_CLIENT_ID.apps.googleusercontent.com")
   ```

---

## 🧩 **3. Android Studio Configuration**

* Added required permissions in `AndroidManifest.xml`:

  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  ```
* Applied the Google Services plugin at the bottom of **app/build.gradle**:

  ```gradle
  apply plugin: "com.google.gms.google-services"
  ```

---

## 🎨 **4. UI Design (Jetpack Compose)**

All UI is written in **Compose**, not XML.
Main screen includes:

* Text fields for Email, Password, and optional Phone
* Buttons for:

  * **Sign Up**
  * **Login**
  * **Sign in with Google**
  * **Send OTP / Verify OTP**
* Displays dynamic messages for success and error events.

---

## 💻 **5. Implementation Details**

Main file: **MainActivity.kt**

Contains logic for:

* Email/Password Sign Up & Login
* Google Sign-In using `GoogleSignInClient`
* Phone Authentication using `PhoneAuthProvider`
* Firestore data saving after signup

Firebase methods used:

```kotlin
auth.createUserWithEmailAndPassword(email, password)
auth.signInWithEmailAndPassword(email, password)
auth.signInWithCredential(credential)
auth.signOut()
FirebaseApp.initializeApp(this)
```

Firestore integration:

```kotlin
db.collection("users").document(email).set(hashMapOf("email" to email))
```

---

## 🧪 **6. Testing**

1. Connected an emulator or real Android device with USB debugging.
2. Built and ran the app (`Run → Run 'app'`).
3. Tested:

   * Email/Password registration & login
   * Google Sign-In
   * Phone number OTP verification
4. Verified registered users in Firebase Console → **Authentication → Users**.

---

## ✅ **Expected Output**

* User can register and log in using Email/Password.
* Google Sign-In authenticates users automatically.
* OTP verification for phone number works successfully.
* Logged-in users’ info is stored in Firestore.
* Logout and re-login work as expected.

---

## 🏁 **Conclusion**

The Android application was successfully developed in **Android Studio using Jetpack Compose**, integrated with **Firebase Authentication** and **Cloud Firestore**, enabling secure sign-up and login using **Email/Password**, **Google**, and **Phone OTP** methods.

---

Would you like me to make this look like a **report format (for submission)** — with section numbers, proper headings, and formatting (like a college experiment file)?
