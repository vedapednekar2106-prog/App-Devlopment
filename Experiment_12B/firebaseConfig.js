// firebaseConfig.js
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyBx8_I1lHgZb3lzW8kj-qCWwc8lk8T3BBw",
  authDomain: "authreact-2633a.firebaseapp.com",
  projectId: "authreact-2633a",
  storageBucket: "authreact-2633a.appspot.com",
  messagingSenderId: "818559763005",
  appId: "1:818559763005:web:b078fde548eb9ce3cba054",
};

// Initialize Firebase
export const app = initializeApp(firebaseConfig); // ✅ export 'app'
export const auth = getAuth(app);
