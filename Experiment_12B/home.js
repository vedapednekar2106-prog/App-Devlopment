// app/home.js
import { useRouter } from "expo-router";
import { signOut } from "firebase/auth";
import { Text, TouchableOpacity, View } from "react-native";
import { auth } from "../firebaseConfig";

export default function HomeScreen() {
  const router = useRouter();

  const handleLogout = async () => {
    await signOut(auth);
    router.replace("/login");
  };

  return (
    <View
      style={{
        flex: 1,
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "#fff",
      }}
    >
      <Text style={{ fontSize: 22, fontWeight: "bold", marginBottom: 20 }}>
        Welcome Home 🏠
      </Text>
      <Text style={{ fontSize: 16, marginBottom: 20 }}>
        Logged in as: {auth.currentUser?.email}
      </Text>
      <TouchableOpacity
        onPress={handleLogout}
        style={{
          backgroundColor: "#FF4B4B",
          padding: 12,
          borderRadius: 10,
        }}
      >
        <Text style={{ color: "white", fontWeight: "bold" }}>Sign Out</Text>
      </TouchableOpacity>
    </View>
  );
}
