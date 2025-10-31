Awesome 😄 got it — here’s your polished, professional **README file content** for your project **firebase-auth-react**, written exactly in the same clean and academic style as your friend’s “Experiment 12B” file 👇

---

# **Experiment 12B: Firebase Authentication App using React Native**

---

## **Aim**

To develop a **React Native mobile app** integrated with **Firebase Authentication** that allows users to securely **sign up, log in, and log out** using **Email/Password**, **Google Sign-In**, and **Phone Number Verification**, with proper session management.

---

## **Software and Hardware Requirements**

### **Software:**

* React Native (Expo or React Native CLI)
* Firebase Console (Authentication module)
* Node.js and npm
* Visual Studio Code
* Android Studio / Emulator or physical mobile device for testing

### **Hardware:**

* Windows/Linux/Mac system
* Android or iOS smartphone

---

## **Theory**

**Firebase Authentication** provides secure backend services and SDKs for authenticating users in mobile and web applications. It supports various authentication methods such as **Email/Password**, **Google Sign-In**, and **Phone Number OTP verification**.
**React Native** enables developers to build cross-platform mobile apps using **JavaScript** and **React**, providing native performance and code reusability.

---

## **Steps Followed**

### 1. **Project Setup**

* Created a new React Native project using Expo CLI:

  ```bash
  npx create-expo-app firebase-auth-react
  ```
* Installed Firebase SDK:

  ```bash
  npm install firebase
  ```
* Installed navigation dependencies:

  ```bash
  npm install @react-navigation/native @react-navigation/stack
  ```
* Configured project structure inside `firebase-auth-react/`.

---

### 2. **Firebase Configuration**

* Created a new project in **Firebase Console**.
* Enabled the following authentication methods:

  * **Email/Password**
  * **Google Sign-In**
  * **Phone Number**
* Obtained the **Firebase configuration object** and stored it in:

  ```js
  firebaseConfig.js
  ```
* Initialized Firebase using:

  ```js
  import { initializeApp } from "firebase/app";
  const app = initializeApp(firebaseConfig);
  ```

---

### 3. **App Implementation**

* Created the following main screens inside the project:

  * `LoginScreen.js` → Allows users to log in with Email, Google, or Phone
  * `SignupScreen.js` → Handles new user registration
  * `HomeScreen.js` → Displays after successful login with logout option
  * `PhoneAuthScreen.js` → Implements OTP-based authentication
  * `GoogleAuth.js` → Handles Google Sign-In flow
  * `Layout.js` and `index.js` → Handle app routing and navigation

---

### 4. **Authentication Functions**

Used Firebase Authentication SDK methods:

```javascript
createUserWithEmailAndPassword()
signInWithEmailAndPassword()
signInWithPopup() // for Google Sign-In
signInWithPhoneNumber()
signOut()
```

* Implemented **OTP verification** for phone-based login.
* Used **Google Sign-In** through Firebase’s `GoogleAuthProvider`.
* Managed **session persistence** with Firebase’s authentication state observer to automatically keep users logged in.

---

### 5. **Navigation Setup**

* Implemented app navigation using React Navigation:

  ```bash
  npm install @react-navigation/native @react-navigation/stack
  ```
* Created a navigation stack for:

  * **Login**
  * **Signup**
  * **Home**
  * **Phone Auth**
* Controlled navigation flow based on authentication state.

---

### 6. **Testing**

* Deployed the app on **Expo Go** and tested on a physical Android device.
* Verified:

  * User registration with Email/Password
  * Login with Google Sign-In
  * OTP verification for Phone Number login
  * Session persistence after reload
  * Logout functionality

---

## **Output**

* User can register using Email and Password.
* User can log in via **Google Sign-In** or **Phone Number OTP**.
* Successful login redirects to **Home Screen**.
* Logout clears the session and returns to login page.
* Session remains active until explicitly logged out.

---

## **Result**

Successfully developed a **React Native app integrated with Firebase Authentication** to perform user sign-up, login, and logout, and manage session states securely

The app provides a **secure**, **cross-platform**, and **user-friendly authentication experience** using Firebase.

---

