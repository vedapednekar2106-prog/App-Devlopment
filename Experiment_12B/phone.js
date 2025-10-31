// app/phone.js
import { FirebaseRecaptchaVerifierModal } from "expo-firebase-recaptcha";
import { useRouter } from "expo-router";
import { PhoneAuthProvider, signInWithCredential } from "firebase/auth";
import { useState } from "react";
import { Alert, Text, TextInput, TouchableOpacity, View } from "react-native";
import { auth, firebaseConfig } from "../firebaseConfig";

export default function PhoneLogin() {
  const [phoneNumber, setPhoneNumber] = useState("");
  const [verificationId, setVerificationId] = useState(null);
  const [otp, setOtp] = useState("");
  const recaptchaVerifier = useState(null);
  const router = useRouter();

  const sendVerification = async () => {
    try {
      const provider = new PhoneAuthProvider(auth);
      const id = await provider.verifyPhoneNumber(
        phoneNumber,
        recaptchaVerifier.current
      );
      setVerificationId(id);
      Alert.alert("Success", "OTP sent to your phone");
    } catch (err) {
      Alert.alert("Error", err.message);
    }
  };

  const confirmCode = async () => {
    try {
      const credential = PhoneAuthProvider.credential(verificationId, otp);
      await signInWithCredential(auth, credential);
      Alert.alert("Success", "Phone login successful 🎉");
      router.replace("/home");
    } catch (err) {
      Alert.alert("Error", err.message);
    }
  };

  return (
    <View style={{ flex: 1, justifyContent: "center", padding: 20 }}>
      <FirebaseRecaptchaVerifierModal
        ref={recaptchaVerifier}
        firebaseConfig={firebaseConfig}
      />

      <Text style={{ fontSize: 26, fontWeight: "bold", marginBottom: 20 }}>
        Sign in with Phone 📱
      </Text>

      {!verificationId ? (
        <>
          <TextInput
            placeholder="+91 9876543210"
            value={phoneNumber}
            onChangeText={setPhoneNumber}
            keyboardType="phone-pad"
            style={{
              borderWidth: 1,
              borderColor: "#ccc",
              borderRadius: 10,
              padding: 12,
              marginBottom: 20,
            }}
          />
          <TouchableOpacity
            onPress={sendVerification}
            style={{
              backgroundColor: "#34A853",
              padding: 15,
              borderRadius: 10,
              alignItems: "center",
            }}
          >
            <Text style={{ color: "white", fontWeight: "bold", fontSize: 16 }}>
              Send OTP
            </Text>
          </TouchableOpacity>
        </>
      ) : (
        <>
          <TextInput
            placeholder="Enter OTP"
            value={otp}
            onChangeText={setOtp}
            keyboardType="number-pad"
            style={{
              borderWidth: 1,
              borderColor: "#ccc",
              borderRadius: 10,
              padding: 12,
              marginBottom: 20,
            }}
          />
          <TouchableOpacity
            onPress={confirmCode}
            style={{
              backgroundColor: "#007BFF",
              padding: 15,
              borderRadius: 10,
              alignItems: "center",
            }}
          >
            <Text style={{ color: "white", fontWeight: "bold", fontSize: 16 }}>
              Verify OTP
            </Text>
          </TouchableOpacity>
        </>
      )}
    </View>
  );
}
