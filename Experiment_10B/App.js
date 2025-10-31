import { Ionicons } from "@expo/vector-icons";
import { initializeApp } from "firebase/app";
import {
  getAuth,
  onAuthStateChanged,
  signInAnonymously,
} from "firebase/auth";
import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDocs,
  getFirestore,
  orderBy,
  query,
  serverTimestamp,
  updateDoc,
  where,
} from "firebase/firestore";
import { useEffect, useState } from "react";
import {
  ActivityIndicator,
  Alert,
  FlatList,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from "react-native";

// ✅ Correct Firebase Config (no analytics, no duplicates)
const firebaseConfig = {
  apiKey: "AIzaSyBoxKmXPA7hU2s6ozQD2CsMgR-2xiStNrw",
  authDomain: "todoapp-69605.firebaseapp.com",
  projectId: "todoapp-69605",
  storageBucket: "todoapp-69605.appspot.com", // ✅ fixed .appspot.com
  messagingSenderId: "612633888859",
  appId: "1:612633888859:web:7d7fc538cd7cf34753577e",
};

// 🔧 Initialize Firebase once
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

export default function App() {
  const [task, setTask] = useState("");
  const [tasks, setTasks] = useState([]);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // ✅ Sign in anonymously & load tasks
  useEffect(() => {
    const signIn = async () => {
      try {
        await signInAnonymously(auth);
      } catch (e) {
        console.error("Auth Error:", e.message);
      }
    };
    signIn();

    const unsub = onAuthStateChanged(auth, (u) => {
      if (u) {
        setUser(u);
        loadTasks(u.uid);
      } else {
        console.warn("User not signed in.");
      }
    });

    return unsub;
  }, []);

  // ✅ Add new task
  const addTask = async () => {
    if (!task.trim()) return Alert.alert("Empty Task", "Please enter a task.");
    if (!user) return Alert.alert("Error", "User not authenticated.");

    try {
      await addDoc(collection(db, "tasks"), {
        task,
        completed: false,
        createdAt: serverTimestamp(),
        userId: user.uid,
      });
      setTask("");
      loadTasks(user.uid);
    } catch (e) {
      console.error("Add Error:", e.message);
    }
  };

  // ✅ Load user's tasks
  const loadTasks = async (uid) => {
    try {
      setLoading(true);
      const q = query(
        collection(db, "tasks"),
        where("userId", "==", uid),
        orderBy("createdAt", "desc")
      );
      const querySnapshot = await getDocs(q);
      const list = [];
      querySnapshot.forEach((docSnap) =>
        list.push({ id: docSnap.id, ...docSnap.data() })
      );
      setTasks(list);
    } catch (e) {
      console.error("Load Error:", e.message);
    } finally {
      setLoading(false);
    }
  };

  // ✅ Toggle complete/incomplete
  const toggleComplete = async (id, currentStatus) => {
    try {
      await updateDoc(doc(db, "tasks", id), { completed: !currentStatus });
      if (user) loadTasks(user.uid);
    } catch (e) {
      console.error("Update Error:", e.message);
    }
  };

  // ✅ Delete task
  const deleteTask = async (id) => {
    try {
      await deleteDoc(doc(db, "tasks", id));
      if (user) loadTasks(user.uid);
    } catch (e) {
      console.error("Delete Error:", e.message);
    }
  };

  // 🕐 Show loader while fetching
  if (loading) {
    return (
      <View style={styles.loaderContainer}>
        <ActivityIndicator size="large" color="#007bff" />
        <Text style={{ marginTop: 10, color: "#555" }}>Loading tasks...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>📝 My To-Do List</Text>

      {/* Input Field */}
      <View style={styles.inputContainer}>
        <TextInput
          placeholder="Enter a new task..."
          value={task}
          onChangeText={setTask}
          style={styles.input}
        />
        <TouchableOpacity onPress={addTask} style={styles.addButton}>
          <Text style={styles.addText}>Add</Text>
        </TouchableOpacity>
      </View>

      {/* Tasks List */}
      {tasks.length === 0 ? (
        <Text style={styles.emptyText}>No tasks yet. Add one above!</Text>
      ) : (
        <FlatList
          data={tasks}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <View style={styles.taskItem}>
              {/* Checkbox */}
              <TouchableOpacity
                onPress={() => toggleComplete(item.id, item.completed)}
              >
                <Ionicons
                  name={item.completed ? "checkbox" : "square-outline"}
                  size={24}
                  color={item.completed ? "green" : "gray"}
                />
              </TouchableOpacity>

              {/* Task Text */}
              <Text
                style={[
                  styles.taskText,
                  {
                    textDecorationLine: item.completed ? "line-through" : "none",
                    color: item.completed ? "gray" : "black",
                  },
                ]}
              >
                {item.task}
              </Text>

              {/* Delete Button */}
              <TouchableOpacity onPress={() => deleteTask(item.id)}>
                <Ionicons name="close-circle" size={26} color="red" />
              </TouchableOpacity>
            </View>
          )}
        />
      )}
    </View>
  );
}

// 🎨 Styles
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F8F9FA",
    padding: 20,
    paddingTop: 60,
  },
  title: {
    fontSize: 26,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 20,
    textAlign: "center",
  },
  inputContainer: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 20,
  },
  input: {
    flex: 1,
    borderWidth: 1,
    borderColor: "#ccc",
    backgroundColor: "#fff",
    borderRadius: 10,
    padding: 12,
    fontSize: 16,
  },
  addButton: {
    backgroundColor: "#007bff",
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderRadius: 10,
    marginLeft: 10,
  },
  addText: {
    color: "#fff",
    fontWeight: "bold",
  },
  taskItem: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#fff",
    borderRadius: 10,
    padding: 14,
    marginBottom: 10,
    justifyContent: "space-between",
    shadowColor: "#000",
    shadowOpacity: 0.1,
    shadowRadius: 5,
    elevation: 2,
  },
  taskText: {
    flex: 1,
    marginLeft: 10,
    fontSize: 16,
  },
  emptyText: {
    textAlign: "center",
    color: "#888",
    fontSize: 16,
    marginTop: 20,
  },
  loaderContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#F8F9FA",
  },
});
