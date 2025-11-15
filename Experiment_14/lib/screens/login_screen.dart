import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ===================================================
  // EMAIL LOGIN
  // ===================================================
  Future<void> _loginWithEmail() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        _showSnack("Please enter both email and password.", Colors.red);
        return;
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ⭐️ DO NOT RESET isPremium HERE
      await _createUserIfNotExists(userCredential.user!);

      _showSnack("Login successful! 🎉", Colors.green);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? "Login failed.", Colors.red);
    }
  }

  // ===================================================
  // EMAIL SIGN UP
  // ===================================================
  Future<void> _signUpWithEmail() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        _showSnack("Please enter both email and password.", Colors.red);
        return;
      }

      final userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // New users get NON-PREMIUM initially
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': 'New Wanderer',
        'username': email.split('@')[0],
        'isPremium': false,
        'isAdmin': false,
        'lastLogin': DateTime.now().toIso8601String(),
        'deleted': false,
      });

      _showSnack("Account created successfully! 🎉", Colors.green);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? "Sign-up failed.", Colors.red);
    }
  }

  // ===================================================
  // GOOGLE SIGN IN
  // ===================================================
  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      await _createUserIfNotExists(userCredential.user!);

      _showSnack("Google sign-in successful! ✅", Colors.green);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      _showSnack("Google sign-in failed.", Colors.red);
    }
  }

  // ===================================================
  // GUEST LOGIN
  // ===================================================
  Future<void> _continueAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      await _firestore.collection('users').doc(user!.uid).set({
        'email': 'guest_${user.uid.substring(0, 8)}@wanderlist.com',
        'displayName': 'Wanderer Guest',
        'isPremium': false,
        'isAdmin': false,
        'username': '@guest',
        'lastLogin': DateTime.now().toIso8601String(),
        'deleted': false,
      }, SetOptions(merge: true));

      _showSnack("Continuing as Guest 👤", Colors.orange);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      _showSnack("Guest login failed.", Colors.red);
    }
  }

  // ===================================================
  // CREATE USER ONLY IF NOT EXISTS (PREMIUM SAFE)
  // ===================================================
  Future<void> _createUserIfNotExists(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      // Create ONLY if new user → Default: NOT PREMIUM
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email ?? 'email_not_provided',
        'displayName': user.displayName ?? 'New Wanderer',
        'username': user.email?.split('@')[0] ?? '@newuser',
        'isPremium': false,
        'isAdmin': false,
        'lastLogin': DateTime.now().toIso8601String(),
        'deleted': false,
      });
    } else {
      // Existing user → DO NOT RESET PREMIUM
      await _firestore.collection('users').doc(user.uid).set({
        'lastLogin': DateTime.now().toIso8601String(),
        'deleted': false,
      }, SetOptions(merge: true));
    }
  }

  // ===================================================
  // SNACKBAR
  // ===================================================
  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ===================================================
  // UI
  // ===================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/icons/bg.png"),
                fit: BoxFit.cover,
                colorFilter:
                    ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),

                  Center(
                    child: Column(
                      children: const [
                        Icon(Icons.lock_outline, color: Colors.white, size: 36),
                        SizedBox(height: 8),
                        Text(
                          "WanderList",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Your next adventure awaits",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  const Text("Email", style: TextStyle(color: Colors.white)),
                  TextField(
                    controller: _emailController,
                    decoration: _inputDecoration("Enter your email"),
                  ),
                  const SizedBox(height: 20),

                  const Text("Password", style: TextStyle(color: Colors.white)),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration("Enter your password"),
                  ),
                  const SizedBox(height: 15),

                  _authButton("Login", _loginWithEmail, const Color(0xFFFF8C00)),
                  const SizedBox(height: 15),

                  _authButton("Sign Up", _signUpWithEmail, Colors.white24,
                      textColor: Colors.white),
                  const SizedBox(height: 25),

                  const Center(
                    child: Text("Or continue with",
                        style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 15),

                  Center(
                    child: GestureDetector(
                      onTap: _signInWithGoogle,
                      child: Container(
                        height: 50,
                        width: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/icons/google_logo.png",
                                height: 28),
                            const SizedBox(width: 10),
                            const Text("Sign in with Google",
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: TextButton(
                      onPressed: _continueAsGuest,
                      child: const Text(
                        "Continue as Guest",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white70,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );

  Widget _authButton(String text, VoidCallback onTap, Color bg,
      {Color textColor = Colors.white}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Text(text, style: TextStyle(fontSize: 16, color: textColor)),
      ),
    );
  }
}
