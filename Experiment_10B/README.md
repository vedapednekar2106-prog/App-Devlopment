# Experiment 10: To-Do List App (React Native) using Firebase 

## Experiment Aim
To develop a **React Native To-Do List app** that allows users to **add, update, delete, and mark tasks as completed** while storing all task data in **Firebase Firestore**, enabling real-time synchronization and persistent storage across devices.

---

## Steps Followed

1. **Project Setup**
   - Created a new React Native project using Expo:
     ```bash
     expo init firebasetodolist
     ```
   - Installed Firebase SDK:
     ```bash
     npm install firebase
     ```
   - Set up the project folder structure with `App.js` and `firebaseConfig.js`.

2. **Firebase Setup**
   - Created a Firebase project in [Firebase Console](https://console.firebase.google.com/).
   - Enabled **Firestore Database**.
   - Copied Firebase configuration into `firebaseConfig.js`:
     ```javascript
     import { initializeApp } from "firebase/app";
     import { getFirestore } from "firebase/firestore";
    
     const firebaseConfig = {
      apiKey: "AIzaSyBoxKmXPA7hU2s6ozQD2CsMgR-2xiStNrw",
      authDomain: "todoapp-69605.firebaseapp.com",
      projectId: "todoapp-69605",
      storageBucket: "todoapp-69605.appspot.com",
      messagingSenderId: "612633888859",
      appId: "1:612633888859:web:7d7fc538d7cf34753577e",
     };


     const app = initializeApp(firebaseConfig);
     export const db = getFirestore(app);
     ```

3. **Task Functionality**
   - **Add Task:** Users can enter a task in a `TextInput` and press "Add" to store it in Firestore.
   - **Fetch Tasks:** Fetch all tasks from Firestore using `getDocs` and display them in a `FlatList`.
   - **Delete Task:** Remove a task from Firestore using `deleteDoc`.
   - **Mark as Completed:** Toggle a task's completion status using `updateDoc`.

4. **UI Design**
   - Title displayed at the top.
   - Input field with "Add" button for creating new tasks.
   - Task list displayed using `FlatList`.
   - Each task has:
     - **Checkbox** on the left to mark completed.
     - Task name in the center (strikethrough if completed).
     - Delete button on the right.
   - Color-coded elements:
     - Completed tasks: green checkbox
     - Pending tasks: white checkbox
     - Delete button: red

5. **Testing**
   - Verified adding, deleting, and updating tasks on both Android and iOS simulators.
   - Confirmed that tasks are saved and updated in real-time in Firebase Firestore.

---

## Expected Outcome

- Fully functional React Native To-Do List app integrated with Firebase Firestore.
- Users can add, delete, and mark tasks as completed.
- Real-time updates and persistent storage across app sessions.
- Clean and responsive UI with interactive elements.
-