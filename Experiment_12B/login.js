// app/login.js
import { useRouter } from "expo-router";
import { signInWithEmailAndPassword } from "firebase/auth";
import { useEffect, useState } from "react";
import {
    Alert,
    Button,
    Text,
    TextInput,
    TouchableOpacity,
    View,
} from "react-native";
import { auth } from "../firebaseConfig";

import * as Google from "expo-auth-session/providers/google";
import * as WebBrowser from "expo-web-browser";
import { GoogleAuthProvider, signInWithCredential } from "firebase/auth";

// ✅ ensures proper Google OAuth session
WebBrowser.maybeCompleteAuthSession();

export default function LoginScreen() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  // ✅ Google Sign-In setup
  const [request, response, promptAsync] = Google.useAuthRequest({
    iosClientId: "YOUR_IOS_CLIENT_ID.apps.googleusercontent.com",
    androidClientId: "YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com",
    webClientId: "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com",
  });

  useEffect(() => {
    if (response?.type === "success") {
      const { id_token } = response.params;
      const credential = GoogleAuthProvider.credential(id_token);
      signInWithCredential(auth, credential)
        .then(() => {
          Alert.alert("Success", "Signed in with Google 🎉");
          router.replace("/home");
        })
        .catch((error) => Alert.alert("Google Login Failed", error.message));
    }
  }, [response]);

  // ✅ Email/Password login
  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert("Error", "Please enter both email and password");
      return;
    }

    try {
      await signInWithEmailAndPassword(auth, email, password);
      Alert.alert("Success", "Login Successful 🎉");
      router.replace("/home");
    } catch (error) {
      console.error(error);
      Alert.alert("Login Failed", error.message);
    }
  };

  return (
    <View
      style={{
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "#fff",
        padding: 20,
      }}
    >
      <Text style={{ fontSize: 26, fontWeight: "bold", marginBottom: 30 }}>
        Login 🔐
      </Text>

      {/* Email & Password Inputs */}
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        style={{
          width: "100%",
          borderWidth: 1,
          borderColor: "#ccc",
          padding: 12,
          borderRadius: 10,
          marginBottom: 15,
        }}
      />

      <TextInput
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        style={{
          width: "100%",
          borderWidth: 1,
          borderColor: "#ccc",
          padding: 12,
          borderRadius: 10,
          marginBottom: 25,
        }}
      />

      {/* Email Login Button */}
      <TouchableOpacity
        onPress={handleLogin}
        style={{
          backgroundColor: "#007BFF",
          padding: 15,
          borderRadius: 10,
          width: "100%",
          alignItems: "center",
        }}
      >
        <Text style={{ color: "white", fontWeight: "bold", fontSize: 16 }}>
          Login
        </Text>
      </TouchableOpacity>

      {/* Google Sign-In Button */}
      <View style={{ marginTop: 25, width: "100%" }}>
        <Button
          disabled={!request}
          title="Sign in with Google"
          onPress={() => promptAsync()}
        />
      </View>

      {/* Phone Sign-In Placeholder */}
      <TouchableOpacity
        onPress={() => router.push("/phone")}
        style={{ marginTop: 15 }}
      >
        <Text style={{ color: "#34A853", fontWeight: "500" }}>
          Sign in with Phone 📱
        </Text>
      </TouchableOpacity>

      {/* Signup Link */}
      <TouchableOpacity
        onPress={() => router.push("/signup")}
        style={{ marginTop: 20 }}
      >
        <Text style={{ color: "#007BFF" }}>
          Don't have an account? Sign up
        </Text>
      </TouchableOpacity>
    </View>
  );
}
