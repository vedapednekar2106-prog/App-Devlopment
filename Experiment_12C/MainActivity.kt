package com.example.firebaselogin

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import com.google.android.gms.auth.api.signin.*
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseException
import com.google.firebase.auth.*
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.delay
import java.util.concurrent.TimeUnit

class MainActivity : ComponentActivity() {
    private lateinit var auth: FirebaseAuth
    private lateinit var db: FirebaseFirestore
    private lateinit var googleSignInClient: GoogleSignInClient
    private lateinit var googleLauncher: ActivityResultLauncher<Intent>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ✅ Ensure Firebase initializes before anything else
        FirebaseApp.initializeApp(this)

        auth = FirebaseAuth.getInstance()
        db = FirebaseFirestore.getInstance()

        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken("336391913077-1e3gi0irctsuma6jqkiajlfofmeumbti.apps.googleusercontent.com")
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(this, gso)

        // ✅ Register launcher here, not inside Composable
        googleLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            if (result.resultCode == Activity.RESULT_OK) {
                val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
                try {
                    val account = task.result
                    val credential = GoogleAuthProvider.getCredential(account.idToken, null)
                    auth.signInWithCredential(credential)
                        .addOnSuccessListener {
                            db.collection("users").document(account.email ?: "noemail")
                                .set(hashMapOf("email" to account.email))
                        }
                        .addOnFailureListener { e ->
                            e.printStackTrace()
                        }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }

        setContent {
            FirebaseAuthApp(auth, db, googleSignInClient, googleLauncher)
        }
    }
}

@Composable
fun FirebaseAuthApp(
    auth: FirebaseAuth,
    db: FirebaseFirestore,
    googleSignInClient: GoogleSignInClient,
    googleLauncher: ActivityResultLauncher<Intent>
) {
    val activity = LocalContext.current as Activity
    var screenMessage by remember { mutableStateOf<String?>(null) }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var phone by remember { mutableStateOf("") }
    var otp by remember { mutableStateOf("") }
    var verificationId by remember { mutableStateOf<String?>(null) }

    // Temporary message overlay
    if (screenMessage != null) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Text(screenMessage ?: "", style = MaterialTheme.typography.headlineMedium)
        }
        LaunchedEffect(screenMessage) {
            delay(2500)
            screenMessage = null
        }
        return
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("🔥 Firebase Auth App", style = MaterialTheme.typography.headlineSmall)
        Spacer(modifier = Modifier.height(16.dp))

        // Email & Password
        OutlinedTextField(value = email, onValueChange = { email = it }, label = { Text("Email") })
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            visualTransformation = PasswordVisualTransformation()
        )

        Spacer(modifier = Modifier.height(8.dp))

        Button(onClick = {
            auth.signInWithEmailAndPassword(email, password)
                .addOnSuccessListener { screenMessage = "✅ Login Successful!" }
                .addOnFailureListener { screenMessage = "❌ ${it.localizedMessage}" }
        }) { Text("Login") }

        Button(onClick = {
            auth.createUserWithEmailAndPassword(email, password)
                .addOnSuccessListener {
                    db.collection("users").document(email).set(hashMapOf("email" to email))
                    screenMessage = "🎉 Sign Up Successful!"
                }
                .addOnFailureListener { screenMessage = it.localizedMessage }
        }) { Text("Sign Up") }

        Spacer(modifier = Modifier.height(20.dp))
        Divider()
        Spacer(modifier = Modifier.height(20.dp))

        // ✅ Google Sign-In (now uses registered launcher)
        Button(onClick = {
            googleLauncher.launch(googleSignInClient.signInIntent)
        }) { Text("Sign in with Google") }

        Spacer(modifier = Modifier.height(20.dp))
        Divider()
        Spacer(modifier = Modifier.height(20.dp))

        // ✅ Phone Auth
        OutlinedTextField(
            value = phone,
            onValueChange = { phone = it },
            label = { Text("Phone (+countrycode...)") }
        )

        if (verificationId == null) {
            Button(onClick = {
                val options = PhoneAuthOptions.newBuilder(auth)
                    .setPhoneNumber(phone)
                    .setTimeout(60L, TimeUnit.SECONDS)
                    .setActivity(activity)
                    .setCallbacks(object : PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
                        override fun onVerificationCompleted(credential: PhoneAuthCredential) {
                            auth.signInWithCredential(credential)
                                .addOnSuccessListener { screenMessage = "📲 Phone Login Success!" }
                                .addOnFailureListener {
                                    screenMessage = "❌ ${it.localizedMessage}"
                                }
                        }

                        override fun onVerificationFailed(e: FirebaseException) {
                            screenMessage = "⚠️ Failed: ${e.localizedMessage}"
                        }

                        override fun onCodeSent(verificationIdParam: String, token: PhoneAuthProvider.ForceResendingToken) {
                            verificationId = verificationIdParam
                            screenMessage = "📩 OTP Sent!"
                        }
                    }).build()
                PhoneAuthProvider.verifyPhoneNumber(options)
            }) { Text("Send OTP") }
        } else {
            OutlinedTextField(value = otp, onValueChange = { otp = it }, label = { Text("Enter OTP") })
            Button(onClick = {
                val credential = PhoneAuthProvider.getCredential(verificationId!!, otp)
                auth.signInWithCredential(credential)
                    .addOnSuccessListener {
                        screenMessage = "🎉 Phone Sign-In Successful!"
                        verificationId = null
                    }
                    .addOnFailureListener { screenMessage = "❌ ${it.localizedMessage}" }
            }) { Text("Verify OTP") }
        }
    }
}
