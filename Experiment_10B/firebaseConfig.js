// firebaseConfig.js
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
