import { createUserWithEmailAndPassword, getAuth, signInWithEmailAndPassword } from "firebase/auth";
import { useState } from "react";
import { Button, StyleSheet, Text, TextInput, View } from "react-native";
import { app } from "./firebaseConfig";

export default function App() {
  const auth = getAuth(app);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");

  const signUp = async () => {
    try {
      await createUserWithEmailAndPassword(auth, email, password);
      setMessage("✅ Account created successfully!");
    } catch (error) {
      setMessage("❌ " + error.message);
    }
  };

  const signIn = async () => {
    try {
      await signInWithEmailAndPassword(auth, email, password);
      setMessage("✅ Signed in successfully!");
    } catch (error) {
      setMessage("❌ " + error.message);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Firebase Auth Demo</Text>
      <TextInput
        style={styles.input}
        placeholder="Email"
        onChangeText={setEmail}
        value={email}
      />
      <TextInput
        style={styles.input}
        placeholder="Password"
        secureTextEntry
        onChangeText={setPassword}
        value={password}
      />
      <Button title="Sign Up" onPress={signUp} />
      <Button title="Sign In" onPress={signIn} />
      <Text style={styles.message}>{message}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    padding: 20,
    backgroundColor: "#fff",
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    marginBottom: 20,
    textAlign: "center",
  },
  input: {
    borderWidth: 1,
    borderColor: "#ccc",
    marginBottom: 10,
    padding: 10,
    borderRadius: 5,
  },
  message: {
    textAlign: "center",
    marginTop: 20,
    color: "#333",
  },
});
