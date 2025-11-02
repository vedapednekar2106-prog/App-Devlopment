import * as Google from "expo-auth-session/providers/google";
import * as WebBrowser from "expo-web-browser";
import { GoogleAuthProvider, signInWithCredential } from "firebase/auth";
import { useEffect } from "react";
import { Button, Text, View } from "react-native";
import { auth } from "../firebaseConfig";

WebBrowser.maybeCompleteAuthSession();

export default function GoogleSignIn() {
  const [request, response, promptAsync] = Google.useAuthRequest({
    webClientId: "818559763005-u1fo78n87ljnug9n813tat6s3jl1fvur.apps.googleusercontent.com.apps.googleusercontent.com",
  });

  useEffect(() => {
    if (response?.type === "success") {
      const { id_token } = response.params;
      const credential = GoogleAuthProvider.credential(id_token);
      signInWithCredential(auth, credential);
    }
  }, [response]);

  return (
    <View style={{ alignItems: "center", marginTop: 20 }}>
      <Button
        disabled={!request}
        title="Sign in with Google"
        onPress={() => promptAsync()}
      />
      <Text style={{ marginTop: 10 }}>Continue with your Google account</Text>
    </View>
  );
}
