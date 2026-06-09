// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showScissorLoader = false;
  bool _isGoogleClicking = false;

  // --- GOOGLE SIGN IN ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleClicking = true);

    try {
      // 1. Open Google Window (App stays still)
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => _isGoogleClicking = false);
        return;
      }

      // 2. Show Scissor Animation ONLY after returning
      setState(() => _showScissorLoader = true);

      // 3. Auth Logic
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _navigateToHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
      }
      setState(() {
        _showScissorLoader = false;
        _isGoogleClicking = false;
      });
    }
  }

  void _continueAsGuest() {
    _navigateToHome();
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkSlate = Color(0xFF2F4F4F);

    return Scaffold(
      backgroundColor: darkSlate,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // --- LOGO ---
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    size: 70,
                    color: darkSlate,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "M Khalil Tailors",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Professional Tailoring Management",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const Spacer(),

                // --- BUTTONS ---
                if (_showScissorLoader)
                  const ScissorLoader()
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isGoogleClicking ? null : _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBackgroundColor: Colors.white.withOpacity(0.7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isGoogleClicking)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey,
                              ),
                            )
                          else
                            // --- LOCAL ASSET IMAGE ---
                            Image.asset(
                              'assets/google.png',
                              height: 24,
                              // If image is missing, show icon as backup
                              errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.g_mobiledata,
                                color: Colors.blue,
                                size: 30,
                              ),
                            ),
                          const SizedBox(width: 15),
                          const Text(
                            "Continue with Google",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: _isGoogleClicking ? null : _continueAsGuest,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    child: const Text(
                      "Skip & Work Offline",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScissorLoader extends StatefulWidget {
  const ScissorLoader({super.key});

  @override
  State<ScissorLoader> createState() => _ScissorLoaderState();
}

class _ScissorLoaderState extends State<ScissorLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: -0.2 + (_controller.value * 0.5),
              child: const Icon(
                Icons.content_cut,
                size: 50,
                color: Colors.white,
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        const Text("Logging in...", style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}
